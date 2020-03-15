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

class CheckResultViewWidget extends StatefulWidget {
  CheckResultViewWidget({Key key}) : super(key: key);

  @override
  _CheckResultViewWidget createState() => _CheckResultViewWidget();
}

class _CheckResultViewWidget extends State<CheckResultViewWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.AppDefaultBackgroundColor,
        alignment: Alignment.center,
        child: SafeArea(
          child: Container(
            width: 300,
            height: 200,
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
                          ApplicationHelper.checkResult,
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
                            "再次签到",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}