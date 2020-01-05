package edu.bfa.ss.qin.Util;

public class Student {
    public String ObjectID;
    public String StudentID;
    public String Advertising;
    public String BaiduFaceID;
    public int StudentBeaconID;

    public byte[] getStudentBeaconMinor() {
        byte[] bytes = {0x00, 0x00};
        bytes[0] = (byte)(StudentBeaconID >> 8 & 0xFF);
        bytes[1] = (byte)(StudentBeaconID & 0xFF);
        return bytes;
    }
}
