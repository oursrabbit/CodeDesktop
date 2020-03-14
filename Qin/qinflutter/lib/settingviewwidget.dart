import 'package:camera/camera.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:imagebutton/imagebutton.dart';
import 'package:sign/Model/building.dart';
import 'package:sign/Model/course.dart';
import 'package:sign/Model/professor.dart';
import 'package:sign/Model/room.dart';
import 'package:sign/Model/schedule.dart';
import 'package:sign/applicationhelper.dart';
import 'package:sign/main.dart';
import 'package:sign/scheduleviewwidget.dart';
import 'package:sign/values/colors.dart';
import 'package:sign/values/fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Model/section.dart';

class SettingViewWidget extends StatefulWidget {
  SettingViewWidget({Key key}) : super(key: key);

  @override
  _SettingViewWidget createState() => _SettingViewWidget();
}

class _SettingViewWidget extends State<SettingViewWidget> {

  bool autoLogin = ApplicationHelper.autoLogin;
  bool useBio = ApplicationHelper.useBiometrics;

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
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
                      ),
                    Expanded(child: Container(),),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
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
                    Switch(value: useBio, onChanged: null),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 8, 32, 0),
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
                      onTap: () {
                        //FocusScope.of(context).requestFocus(FocusNode());
                        //this.onLoginButtonPressed(context);
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