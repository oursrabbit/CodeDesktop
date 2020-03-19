import 'package:camera/camera.dart';
import 'package:date_util/date_util.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:url_launcher/url_launcher.dart';

import 'Model/section.dart';
import 'Model/student.dart';
import 'databasehelper.dart';

class HelpViewWidget extends StatefulWidget {
  HelpViewWidget({Key key}) : super(key: key);

  @override
  _HelpViewWidget createState() => _HelpViewWidget();
}

class _HelpViewWidget extends State<HelpViewWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.AppDefaultBackgroundColor,
        alignment: Alignment.center,
        child: SafeArea(
          child: Container(
            width: 300,
            height: 500,
            //color: Colors.green,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 32, 0, 32),
                      child: Container(
                        width: double.infinity,
                        //color: Colors.green,
                        child: Text(
                          "1. 本程序仅对声音学院在校生开放。\n\n2. 初始登陆账号及密码与学校教务系统相同。\n\n3. 首次登陆后请尽快修改密码。\n\n4. 如有其他登陆问题请点击下方按钮联系办公室老师\n\n",
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
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
                      child: Column(
                        children: <Widget>[
                          ImageButton(
                            height: 40,
                            children: <Widget>[
                              Text(
                                "联系办公室",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.NormalText,
                                  fontFamily: FontsHelper.DefaultTextFontFamily,
                                  fontWeight: FontWeight.w400,
                                  fontSize: FontsHelper
                                      .DefaultButtonTextFontSize,
                                ),
                              ),
                            ],
                            pressedImage: Image.asset(
                                "assets/images/buttonbackground.png"),
                            unpressedImage: Image.asset(
                                "assets/images/buttonbackground.png"),
                            onTap: () {
                              launch("http://www.bfa.edu.cn/yx/20180327/");
                            },
                          ),
                          SizedBox(height: 32,),
                          ImageButton(
                            height: 40,
                            children: <Widget>[
                              Text(
                                "返回",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.NormalText,
                                  fontFamily: FontsHelper.DefaultTextFontFamily,
                                  fontWeight: FontWeight.w400,
                                  fontSize: FontsHelper
                                      .DefaultButtonTextFontSize,
                                ),
                              ),
                            ],
                            pressedImage: Image.asset(
                                "assets/images/buttonbackground.png"),
                            unpressedImage: Image.asset(
                                "assets/images/buttonbackground.png"),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}