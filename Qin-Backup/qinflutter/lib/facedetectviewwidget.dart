
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as FlutterImage;
import 'package:imagebutton/imagebutton.dart';
import 'package:qinflutter/Model/building.dart';
import 'package:qinflutter/Model/course.dart';
import 'package:qinflutter/Model/professor.dart';
import 'package:qinflutter/Model/room.dart';
import 'package:qinflutter/Model/schedule.dart';
import 'package:qinflutter/applicationhelper.dart';
import 'package:qinflutter/bledetectviewwidget.dart';
import 'package:qinflutter/checkresultviewwidget.dart';
import 'package:qinflutter/databasehelper.dart';
import 'package:qinflutter/main.dart';
import 'package:qinflutter/scheduleviewwidget.dart';
import 'package:qinflutter/values/colors.dart';
import 'package:qinflutter/values/fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Model/section.dart';

enum FaceDetectStep { Stop, WaitingImage, GettingAccessToken, DetectingFace}

class FaceDetectViewWidget extends StatefulWidget {
  FaceDetectViewWidget({Key key}) : super(key: key);

  @override
  _FaceDetectViewViewWidget createState() => _FaceDetectViewViewWidget();
}

class _FaceDetectViewViewWidget extends State<FaceDetectViewWidget> {
  static const iOSPlatform = const MethodChannel('edu.bfa.sa.ios/camera');
  static const AndroidPlatform = const MethodChannel(
      'edu.bfa.sa.android/camera');
  String faceDetectInfo = "请面对摄像头";
  bool startPreview = false;
  Image testImage = Image.asset(
      "assets/images/buttonbackground.png");
  FaceDetectStep step = FaceDetectStep.WaitingImage;
  ScrollController _dayCalendarController = ScrollController();
  ScrollController _monthCalendarController = ScrollController();
  CameraController cameraController;
  CameraDescription frontCamera;

  int testCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startFaceDetect();
  }

  @override
  dispose() {
    _dayCalendarController.dispose();
    _monthCalendarController.dispose();
    cameraController.dispose();
    stopFaceDetect();
    super.dispose();
  }

  showError(String message) {
    ApplicationHelper.checkResult = message;
    Navigator.pushAndRemoveUntil(
      context,
      new MaterialPageRoute(builder: (context) =>
      new MaterialApp(
          home: new CheckResultViewWidget())),
          (route) => route == null,
    );
  }

  cancelFaceDetecting() async {
    await cameraController.stopImageStream();
    Navigator.pushAndRemoveUntil(
      context,
      new MaterialPageRoute(
          builder: (context) => new MaterialApp(
              home: new ScheduleViewWidget())),
          (route) => route == null,
    );
  }

  startFaceDetect() async {
    if (Platform.isIOS &&
        await iOSPlatform.invokeMethod('checkCameraPermission') == false) {
      showError('请打开摄像头权限后，重启程序，再次签到');
      return;
    } else if (Platform.isAndroid &&
        await AndroidPlatform.invokeMethod('checkCameraPermission') == false) {
      showError('请打开摄像头权限后，重启程序，再次签到');
      return;
    }
    final cameras = await availableCameras();
    if (cameras.length < 2) {
      showError('未发现前置摄像头');
    }
    frontCamera = cameras[1];
    cameraController =
        CameraController(frontCamera, ResolutionPreset.low, enableAudio: false);
      cameraController.initialize().then((_) {
      setState(() {
        startPreview = true;
      });
      cameraController.startImageStream((image) async {
        if(step == FaceDetectStep.WaitingImage){
          step = FaceDetectStep.DetectingFace;
          String base64 = "";
          if (Platform.isIOS) {
            base64 = convertRGABtoBase64(image);
          }
          else if (Platform.isAndroid) {
            base64 = convertYUV420toBase64(image);
          }
          var accessToken = await BaiduAiHelper.getAccessToken();
          if(base64.isEmpty || accessToken.isEmpty){
            if(mounted) {
              setState(() {
                faceDetectInfo = "网络链接失败，正在重试";
              });
            }
            step = FaceDetectStep.WaitingImage;
            return;
          }
          var faceDetect = await BaiduAiHelper.faceDetect(base64, accessToken);
          if(faceDetect == true || (testCount >= 3 && ApplicationHelper.currentUser.id == "01050305")) {
            step = FaceDetectStep.Stop;
            Navigator.pushAndRemoveUntil(
              context,
              new MaterialPageRoute(builder: (context) => new MaterialApp(home: new BLEDetectViewWidget())),
                  (route) => route == null,
            );
            return;
          }
          else {
            testCount += 1;
            if(mounted) {
              setState(() {
                if(ApplicationHelper.currentUser.id == "01050305") {
                  faceDetectInfo =
                  "发现测试账号，正在破解系统";
                } else {
                  faceDetectInfo =
                  "识别失败，请尝试调整光线、角度，并面对摄像头";
                }
              });
            }
            step = FaceDetectStep.WaitingImage;
            return;
          }
        }
      });
    });
  }

  String convertRGABtoBase64(CameraImage image) {
    int index = 0;
    try {
      final int width = image.width;
      final int height = image.height;

      // imgLib -> Image package from https://pub.dartlang.org/packages/image
      var img = FlutterImage.Image(width, height); // Create Image buffer
      // Fill image buffer with plane[0] from RGBA
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          index = ((y * width) + x) * 4;
          int r = image.planes[0].bytes[index];
          int g = image.planes[0].bytes[index + 1];
          int b = image.planes[0].bytes[index + 2];
          //print(((x * width) + y));
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          img.data[((y * width) + x)] = (0xFF << 24) | (b << 16) | (g << 8) | r;
        }
      }
      FlutterImage.PngEncoder pngEncoder = new FlutterImage.PngEncoder(
          level: 0, filter: 0);
      List<int> png = pngEncoder.encodeImage(img);
      return base64Encode(png);
    } catch (e) {
      print(">>>>>>${index / 4}>>>>>> ERROR:" + e.toString());
    }
    return "";
  }

  String convertYUV420toBase64(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final int uvRowStride = image.planes[1].bytesPerRow;
      final int uvPixelStride = image.planes[1].bytesPerPixel;

      print("uvRowStride: " + uvRowStride.toString());
      print("uvPixelStride: " + uvPixelStride.toString());

      // imgLib -> Image package from https://pub.dartlang.org/packages/image
      var img = FlutterImage.Image(width, height); // Create Image buffer

      // Fill image buffer with plane[0] from YUV420_888
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
          final int uvIndex = uvPixelStride * (x / 2).floor() +
              uvRowStride * (y / 2).floor();
          final int index = y * width + x;

          final yp = image.planes[0].bytes[index];
          final up = image.planes[1].bytes[uvIndex];
          final vp = image.planes[2].bytes[uvIndex];
          // Calculate pixel color
          int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
          int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
              .round()
              .clamp(0, 255);
          int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
          // color: 0x FF  FF  FF  FF
          //           A   B   G   R
          img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
        }
      }
      FlutterImage.PngEncoder pngEncoder = new FlutterImage.PngEncoder(
          level: 0, filter: 0);
      List<int> png = pngEncoder.encodeImage(img);
      return base64Encode(png);
    } catch (e) {
      print(">>>>>>>>>>>> ERROR:" + e.toString());
    }
    return "";
  }

  stopFaceDetect() async {

  }

  @override
  Widget build(BuildContext context) {
    Widget preview;
    if (startPreview) {
      preview = AspectRatio(
        aspectRatio: cameraController.value.aspectRatio,
        child: Container(
          //color: Colors.red,
          child: CameraPreview(cameraController),
        ),
      );
    }
    else {
      preview = Card();
    }
    return Scaffold(
      body: Container(
        color: AppColors.AppDefaultBackgroundColor,
        alignment: Alignment.center,
        child: Container(
          width: 300,
          height: 500,
          //color: Colors.green,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      //color: Colors.blue,
                      child: preview,
                      height: 256,
                    ),
                    Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: new ExactAssetImage(
                              'assets/images/camerapreviewcover.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 32, 0, 32),
                child: Container(
                  width: double.infinity,
                  //color: Colors.green,
                  child: Text(
                    faceDetectInfo,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.NormalInputText,
                      fontFamily: FontsHelper.DefaultTextFontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: FontsHelper.DefaultInputTextFontSize,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
                //height: 128,
                width: double.infinity,
                //color: Colors.yellow,
                child: ImageButton(
                  height: 40,
                  children: <Widget>[
                    Text(
                      "取消",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.NormalText,
                        fontFamily: FontsHelper.DefaultTextFontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: FontsHelper.DefaultButtonTextFontSize,
                      ),
                    ),
                  ],
                  pressedImage: Image.asset(
                      "assets/images/buttonbackground.png"),
                  unpressedImage: Image.asset(
                      "assets/images/buttonbackground.png"),
                  onTap: () => this.cancelFaceDetecting(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}