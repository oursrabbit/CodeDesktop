import 'package:camera/camera.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imagebutton/imagebutton.dart';
//import 'package:qrcode_reader/qrcode_reader.dart';
import 'package:sign/Model/building.dart';
import 'package:sign/Model/course.dart';
import 'package:sign/Model/professor.dart';
import 'package:sign/Model/room.dart';
import 'package:sign/Model/schedule.dart';
import 'package:sign/aboutviewwidget.dart';
import 'package:sign/applicationhelper.dart';
import 'package:sign/buildinglistviewwidget.dart';
import 'package:sign/facedetectviewwidget.dart';
import 'package:sign/main.dart';
import 'package:sign/scheduleviewwidget.dart';
import 'package:sign/values/colors.dart';
import 'package:sign/values/fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Model/section.dart';
import 'Model/student.dart';
import 'applicationhelper.dart';
import 'applicationhelper.dart';
import 'applicationhelper.dart';
import 'applicationhelper.dart';
import 'checkresultviewwidget.dart';
import 'databasehelper.dart';
import 'historyviewwidget.dart';
import 'initviewwidget.dart';

class SettingViewWidget extends StatefulWidget {
  SettingViewWidget({Key key}) : super(key: key);

  @override
  _SettingViewWidget createState() => _SettingViewWidget();
}

class _SettingViewWidget extends State<SettingViewWidget> {

  bool autoLogin = ApplicationHelper.autoLogin;
  bool useBio = ApplicationHelper.useBiometrics;

  void onCustomSignInButtonPressed(BuildContext context) {
    ApplicationHelper.isCustomCheckIn = true;
    ApplicationHelper.checkSchedule = new Schedule();
    Navigator.of(context).pop();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) {
      return BuildingListViewViewWidget();
    }));
  }

  void onResetPasswordButtonPressed(BuildContext context) async {
    if (ApplicationHelper.currentUser.email == "NONE") {
      showDialog(
        context: context,
        builder: (context) =>
            CupertinoAlertDialog(
              title: Text("修改密码失败"),
              content: Text("未设置邮箱，请联系班主任重置密码"),
              actions: <Widget>[
                FlatButton(
                  child: new Text("确定"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    } else {
      await DatabaseHelper.leanCloudResetPassword(
          ApplicationHelper.currentUser.email);
      showDialog(
        context: context,
        builder: (context) =>
            CupertinoAlertDialog(
              title: Text("已发送"),
              content: Text("密码重置邮件已发送至注册邮箱"),
              actions: <Widget>[
                FlatButton(
                  child: new Text("确定"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget useBioButton = Container();
    if(ApplicationHelper.canCheckBiometrics == true) {
      useBioButton = Padding(
        padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
        child: Row(
          children: <Widget>[
            FlatButton(
              child: Text(
                "面部/指纹登陆",
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: AppColors.PrimaryBackground,
                  fontFamily: FontsHelper.DefaultTextFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: FontsHelper.DefaultButtonTextFontSize,
                ),
              ),
            ),
            Expanded(child: Container(),),
            Switch(value: useBio, onChanged: (value) async {
              if(await ApplicationHelper.checkBiometrics() == true ) {
                ApplicationHelper.setLocalDatabaseBool('useBiometrics useBiometrics', value);
                ApplicationHelper.useBiometrics = value;
                setState(() {
                  useBio = value;
                });
              }
            }),
          ],
        ),
      );
    }
    return Scaffold(
      body: Container(
        color: AppColors.AppDefaultBackgroundColor,
        alignment: Alignment.centerLeft,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: Row(children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      //color: Colors.blue,
                      child: Image.asset(
                        'assets/images/backbutton.png', fit: BoxFit.fill,),
                    ),
                  ),
                  Expanded(child: Container(),)
                ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 8, 32, 0),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "查看签到记录",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.PrimaryBackground,
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: FontsHelper.DefaultButtonTextFontSize,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) {
                          return HistoryViewViewWidget();
                        }));
                      },
                    ),
                    Expanded(child: Container(),),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 8, 32, 0),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "自主签到",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.PrimaryBackground,
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: FontsHelper.DefaultButtonTextFontSize,
                        ),
                      ),
                      onPressed: () => this.onCustomSignInButtonPressed(context),
                    ),
                    Expanded(child: Container(),),
                  ],
                ),
              ),
              useBioButton,
              Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "自动登陆",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.PrimaryBackground,
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: FontsHelper.DefaultButtonTextFontSize,
                        ),
                      ),
                    ),
                    Expanded(child: Container(),),
                    Switch(value: autoLogin, onChanged: (value) {
                      ApplicationHelper.setLocalDatabaseBool('autoLogin', value);
                      ApplicationHelper.autoLogin = value;
                      setState(() {
                        autoLogin = value;
                      });
                    }),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "软件信息",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.PrimaryBackground,
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: FontsHelper.DefaultButtonTextFontSize,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) {
                          return AboutViewWidget();
                        }));
                      },
                    ),
                    Expanded(child: Container(),)
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 8, 32, 0),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "隐私政策",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.PrimaryBackground,
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: FontsHelper.DefaultButtonTextFontSize,
                        ),
                      ),
                      onPressed: () => launch(ApplicationHelper.applicationWebSite),
                    ),
                    Expanded(child: Container(),)
                  ],
                ),
              ),Padding(
                padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "修改密码",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.PrimaryBackground,
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: FontsHelper.DefaultButtonTextFontSize,
                        ),
                      ),
                      onPressed: () => this.onResetPasswordButtonPressed(context),
                    ),
                    Expanded(child: Container(),)
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 256,
                    child: ImageButton(
                      height: 40,
                      children: <Widget>[
                        Text(
                          "退出登陆",
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
                      onTap: () async {
                        await ApplicationHelper.setLocalDatabaseBool('autoLogin', false);
                        await ApplicationHelper.setLocalDatabaseBool('useBiometrics', false);
                        Navigator.pushAndRemoveUntil(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                              new MaterialApp(
                                  home: new InitViewWidget())),
                              (route) => route == null,
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}