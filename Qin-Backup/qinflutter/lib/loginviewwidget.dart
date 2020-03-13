import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imagebutton/imagebutton.dart';
import 'package:qinflutter/Model/course.dart';
import 'package:qinflutter/Model/professor.dart';
import 'package:qinflutter/Model/relationbuildingroom.dart';
import 'package:qinflutter/Model/relationstudentgroup.dart';
import 'package:qinflutter/Model/schedule.dart';
import 'package:qinflutter/Model/student.dart';
import 'package:qinflutter/applicationhelper.dart';
import 'package:qinflutter/main.dart';
import 'package:qinflutter/scheduleviewwidget.dart';
import 'package:qinflutter/values/colors.dart';
import 'package:qinflutter/values/fonts.dart';

import 'Model/building.dart';
import 'Model/group.dart';
import 'Model/room.dart';
import 'Model/section.dart';
import 'databasehelper.dart';

class LoginViewWidget extends StatefulWidget {
  LoginViewWidget({Key key}) : super(key: key);

  @override
  _LoginViewWidget createState() => _LoginViewWidget();
}

class _LoginViewWidget extends State<LoginViewWidget> {
  double headerHeight = 250.0;
  String loginInfo = "";
  final myController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(ApplicationHelper.isOpen) {
      if (ApplicationHelper.currentUser.id != null &&
          ApplicationHelper.currentUser.id.isNotEmpty) {
        myController.text = ApplicationHelper.currentUser.id;
        onLoginButtonPressed(context);
      }
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
    ApplicationHelper.isOpen = false;
  }

  void onLoginButtonPressed(BuildContext context) async {
    var currentUser = await Student.getStudentByID(myController.text);
    if (currentUser.id == "NONE") {
      setState(() {
        loginInfo = "未找到用户";
      });
    }
    else {
      setState(() {
        loginInfo = "正在更新建筑信息";
      });
      //MUST BE IN ORDER
      //Group One
      await Building.getAllBuildings();
      await Room.getAllRooms();
      setState(() {
        loginInfo = "正在更新教学信息";
      });
      await Course.getAllCourses();
      await Professor.getAllProfessors();
      await Section.getAllSections();
      await RelationBuildingRoom.getAllRelationBuildingRooms();
      await RelationStudentGroup.getAllRelationStudentGroups();
      //Group Tow
      await Group.getAllGroups();
      ApplicationHelper.currentUser = currentUser;
      await ApplicationHelper.getLocalDatabase(
          "id", ApplicationHelper.currentUser.id);
      setState(() {
        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => new MaterialApp(
              home: new ScheduleViewWidget())),
              (route) => route == null,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          color: AppColors.AppDefaultBackgroundColor,
        ),
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: new ExactAssetImage(
                      'assets/images/logobackgroundimage.png'),
                  fit: BoxFit.fill,
                ),
              ),
              height: headerHeight,
              width: double.infinity,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Positioned(child:
                          Image.asset(
                            "assets/images/logoimage.png",
                          ),)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 12),
                      child: Text(
                        "BFA SOUND SCHOOL",
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(127, 255, 255, 255),
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: FontsHelper.DefaultInputTextFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: TextField(
                  controller: myController,
                  decoration: InputDecoration(
                    hintText: "请输入学号",
                    border: UnderlineInputBorder(),
                  ),
                  style: TextStyle(
                    color: AppColors.NormalInputText,
                    fontFamily: FontsHelper.DefaultTextFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: FontsHelper.DefaultInputTextFontSize,
                  ),
                  onTap: () {
                    setState(() {
                      headerHeight = 0;
                    });
                  },
                  onEditingComplete: () {
                    setState(() {
                      FocusScope.of(context).requestFocus(FocusNode());
                      headerHeight = 220;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(32),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ImageButton(
                      height: 40,
                      children: <Widget>[
                        Text(
                          "登录",
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
                        FocusScope.of(context).requestFocus(FocusNode());
                        this.onLoginButtonPressed(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
              child: Text(
                loginInfo,
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
          ],
        ),
      ),
    );
  }
}