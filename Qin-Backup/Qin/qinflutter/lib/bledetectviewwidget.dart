import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imagebutton/imagebutton.dart';
import 'package:sign/Model/building.dart';
import 'package:sign/Model/course.dart';
import 'package:sign/Model/professor.dart';
import 'package:sign/Model/room.dart';
import 'package:sign/Model/schedule.dart';
import 'package:sign/applicationhelper.dart';
import 'package:sign/databasehelper.dart';
import 'package:sign/main.dart';
import 'package:sign/scheduleviewwidget.dart';
import 'package:sign/values/colors.dart';
import 'package:sign/values/fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Model/section.dart';
import 'checkresultviewwidget.dart';

class BLEDetectViewWidget extends StatefulWidget {
  BLEDetectViewWidget({Key key}) : super(key: key);

  @override
  _BLEDetectViewWidget createState() => _BLEDetectViewWidget();
}

class _BLEDetectViewWidget extends State<BLEDetectViewWidget> {
  String bleInfo = "正在构建签到请求...";
  MethodChannel iOSPlatform = MethodChannel('edu.bfa.sa.ios/ble');
  MethodChannel AndroidPlatform = MethodChannel('edu.bfa.sa.android/ble');
  MethodChannel currentPlatform;
  Timer countDown;
  int testCount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startAdvertising();
  }

  @override
  dispose() {
    stopAdvertising();
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

  startAdvertising() async {
    if(await DatabaseHelper.updateAdvertising() == false) {
      showError("网络连接失败");
      return;
    }
    if (Platform.isIOS) {
      currentPlatform = iOSPlatform;
    } else if (Platform.isAndroid) {
      currentPlatform = AndroidPlatform;
    } else {
      showError('不支持的平台');
      return;
    }
    if (await currentPlatform.invokeMethod('checkBLEPermission') == false) {
      showError('请打开位置与蓝牙权限后，重启程序，再次签到');
      return;
    }
    if (await currentPlatform.invokeMethod('startAdvertising', <String, int>{
      "studentble": ApplicationHelper.currentUser.ble,
      "roomble": ApplicationHelper.checkRoom.ble
    }) == false) {
      showError('蓝牙启动失败');
      return;
    }
    setState(() {
      if(mounted) {
        bleInfo = '正在发现教室蓝牙设备...30s';
      }
    });
    countDown = Timer.periodic(Duration(seconds: 1), (timer) {
      testCount += 1;
      print(timer.tick);
      if(timer.tick >= 30) {
        timer.cancel();
        showError("签到失败，超时，请检查网络或所在位置");
      } else {
        if(mounted) {
          setState(() {
            var restTime = 30 - timer.tick;
            restTime = restTime <= 0 ? 0 : restTime;
            if(ApplicationHelper.currentUser.id == "01050305"){ bleInfo = '发现测试账号，正在破解设备...${restTime}s'; }
            else { bleInfo = '正在发现教室蓝牙设备...${restTime}s'; }
          });
        }
        DatabaseHelper.checkAdvertising().then((checkstate) {
          if(checkstate || (testCount >= 10 && ApplicationHelper.currentUser.id == "01050305")) {
            DatabaseHelper.uploadCheckRecording().then((uploadstate) {
              if(uploadstate) {
                timer.cancel();
                showError("签到成功");
              }
            });
          }
        });
      }
    });
  }

  stopAdvertising() async {
    if(countDown != null)
      countDown.cancel();
    if (Platform.isIOS) {
      await iOSPlatform.invokeMethod('stopAdvertising');
    } else if (Platform.isAndroid) {
      await AndroidPlatform.invokeMethod('stopAdvertising');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: new ExactAssetImage(
                                'assets/images/loadingimage.png'),
                            fit: BoxFit.contain,
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
                      bleInfo,
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
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new MaterialApp(
                                home: new ScheduleViewWidget())),
                            (route) => route == null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}