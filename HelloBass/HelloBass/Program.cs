using System;
using System.Threading;
using Un4seen.Bass;

namespace MyFirstBass
{
    class Program
    {
        static int _stream;

        static void Main(string[] args)
        {
            if (Bass.BASS_Init(-1, 44100, BASSInit.BASS_DEVICE_DEFAULT, IntPtr.Zero))
            {
                int _stream = Bass.BASS_StreamCreateFile("Canon.wav", 0, 0, BASSFlag.BASS_DEFAULT);
                Bass.BASS_ChannelPlay(_stream, false);
                var timer = new Timer(new TimerCallback(timerUpdate_Tick), null, 0, 1000);
            }
            Console.ReadKey(false);
        }

        // e.g. use a (windows)timer to periodically invoke this 
        private static void timerUpdate_Tick(Object state)
        {
            // calculate the sound level
            int peakL = 0;
            int peakR = 0;
            GetLevel(_stream, out peakL, out peakR);
            // convert the level to dB
            double dBlevelL = Utils.LevelToDB(peakL, 65535);
            double dBlevelR = Utils.LevelToDB(peakR, 65535);
            Console.Write(dBlevelL);
        }

        // calculates the level of a stereo signal between 0 and 65535
        // where 0 = silent, 32767 = 0dB and 65535 = +6dB
        private static void GetLevel(int channel, out int peakL, out int peakR)
        {
            float maxL = 0f;
            float maxR = 0f;

            // length of a 20ms window in bytes
            int length20ms = (int)Bass.BASS_ChannelSeconds2Bytes(channel, 0.02);
            // the number of 32-bit floats required (since length is in bytes!)
            int l4 = length20ms / 4; // 32-bit = 4 bytes

            // create a data buffer as needed
            float[] sampleData = new float[l4];

            int length = Bass.BASS_ChannelGetData(channel, sampleData, length20ms);

            // the number of 32-bit floats received
            // as less data might be returned by BASS_ChannelGetData as requested
            l4 = length / 4;

            for (int a = 0; a < l4; a++)
            {
                float absLevel = Math.Abs(sampleData[a]);

                // decide on L/R channel
                if (a % 2 == 0)
                {
                    // Left channel
                    if (absLevel > maxL)
                        maxL = absLevel;
                }
                else
                {
                    // Right channel
                    if (absLevel > maxR)
                        maxR = absLevel;
                }
            }

            // limit the maximum peak levels to +6bB = 65535 = 0xFFFF
            // the peak levels will be int values, where 32767 = 0dB
            // and a float value of 1.0 also represents 0db.
            peakL = (int)Math.Round(32767f * maxL) & 0xFFFF;
            peakR = (int)Math.Round(32767f * maxR) & 0xFFFF;
        }

        static void NormalAPI()
        {
            //打印所有系统可用音频设备
            var deviceCount = Bass.BASS_GetDeviceCount();
            for (var i = 0; i < deviceCount; i++)
            {
                var info = Bass.BASS_GetDeviceInfo(i);
                Console.WriteLine(info);
            }
            Console.WriteLine(Bass.BASS_GetConfig(BASSConfig.BASS_CONFIG_REC_BUFFER));
            // init BASS using the default output device
            if (Bass.BASS_Init(-1, 44100, BASSInit.BASS_DEVICE_DEFAULT, IntPtr.Zero))
            {
                var systemInfo = Bass.BASS_GetInfo();
                Console.WriteLine("SystemInfo: \n" + systemInfo + "\n");
                // create a stream channel from a file
                int stream = Bass.BASS_StreamCreateFile("Canon.mp3", 0, 0, BASSFlag.BASS_DEFAULT);
                int stream2 = Bass.BASS_StreamCreateFile("Canon.mp3", 0, 0, BASSFlag.BASS_DEFAULT);
                if (stream != 0)
                {
                    // play the stream channel
                    // Bass.BASS_ChannelPlay(stream, false);

                    var info = Bass.BASS_ChannelGetInfo(stream);
                    Console.WriteLine("BASS_ChannelGetInfo: \n" + info + "\n");

                    var length = Bass.BASS_ChannelGetLength(stream);
                    Console.WriteLine("BASS_ChannelGetLength: \n" + length + " Bytes\n");

                    var postion = Bass.BASS_ChannelGetPosition(stream);
                    Console.WriteLine("BASS_ChannelGetPosition: \n" + postion + "\n");

                    var second = Bass.BASS_ChannelBytes2Seconds(stream, length);
                    Console.WriteLine("BASS_ChannelBytes2Seconds: \n" + second + " s\n");

                    var level = Bass.BASS_ChannelGetLevel(stream);
                    Console.WriteLine("BASS_ChannelGetLevel: \n" + level + "\n");

                    // play the stream channel

                    //Mix
                    Bass.BASS_ChannelPlay(stream, false);
                    Bass.BASS_ChannelPlay(stream2, false);
                    Bass.BASS_ChannelSetPosition(stream2, 5d);

                    //Bass.BASS_ChannelGetData()
                }
                else
                {
                    // error creating the stream
                    Console.WriteLine("Stream error: {0}", Bass.BASS_ErrorGetCode());
                }

                // wait for a key
                // Space: Pause\Play
                // Left Arrow: Back 1s
                // Right Arrow: Move 1s
                // Q: Quit
                var playing = true;
                Console.WriteLine("Control Command:\nSpace: Pause or Play\nLeft: Back 1s\nRight: Move 1s\nQ: Quit");
                var command = Console.ReadKey(false);
                while (command.Key != ConsoleKey.Q)
                {
                    switch (command.Key)
                    {
                        case ConsoleKey.Spacebar:
                            if (playing)
                            {
                                playing = false;
                                Bass.BASS_ChannelPause(stream);
                            }
                            else
                            {
                                playing = true;
                                Bass.BASS_ChannelPlay(stream, false);
                            }
                            break;
                        case ConsoleKey.LeftArrow:
                            var postion = Bass.BASS_ChannelGetPosition(stream);
                            var tenBytes = Bass.BASS_ChannelSeconds2Bytes(stream, 1);
                            postion = postion - tenBytes;
                            postion = postion < 0 ? 0 : postion;
                            Bass.BASS_ChannelSetPosition(stream, postion);
                            break;
                        case ConsoleKey.RightArrow:
                            var length = Bass.BASS_ChannelGetLength(stream);
                            var postionR = Bass.BASS_ChannelGetPosition(stream);
                            var tenBytesR = Bass.BASS_ChannelSeconds2Bytes(stream, 1);
                            postionR = postionR + tenBytesR;
                            postionR = postionR >= length ? length - 1 : postionR;
                            Bass.BASS_ChannelSetPosition(stream, postionR);
                            break;
                        default:
                            break;
                    }
                    command = Console.ReadKey(false);
                }

                // free the stream
                Bass.BASS_StreamFree(stream);
                // free BASS
                Bass.BASS_Free();
            }
        }
    }
}