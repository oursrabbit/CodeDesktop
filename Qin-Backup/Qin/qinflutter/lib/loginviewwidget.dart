import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:imagebutton/imagebutton.dart';
import 'package:sign/Model/course.dart';
import 'package:sign/Model/professor.dart';
import 'package:sign/Model/relationbuildingroom.dart';
import 'package:sign/Model/relationstudentgroup.dart';
import 'package:sign/Model/student.dart';
import 'package:sign/applicationhelper.dart';
import 'package:sign/databasehelper.dart';
import 'package:sign/values/colors.dart';
import 'package:sign/values/fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Model/building.dart';
import 'Model/group.dart';
import 'Model/room.dart';
import 'Model/section.dart';
import 'applicationhelper.dart';
import 'applicationhelper.dart';
import 'applicationhelper.dart';
import 'scheduleviewwidget.dart';

class LoginViewWidget extends StatefulWidget {
  LoginViewWidget({Key key}) : super(key: key);

  @override
  _LoginViewWidget createState() => _LoginViewWidget();
}

class _LoginViewWidget extends State<LoginViewWidget> {
  String loginInfo = "";
  bool enableLoginButton = true;
  final studentIDTextController = TextEditingController(text: ApplicationHelper.currentUser.id);
  final passwordTextController = TextEditingController();

  bool agreePrivacy = true;

  int loginerrorcount = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), (){
      if(ApplicationHelper.autoLogin == true && ApplicationHelper.openApp == true) {
        setState(() {
          enableLoginButton = false;
        });
        onLoginButtonPressed(context, true);
      }
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    studentIDTextController.dispose();
    passwordTextController.dispose();
    ApplicationHelper.openApp = false;
    super.dispose();
  }

  Future<bool> checkUserExist() async{
    if ((await Student.getStudentByID(studentIDTextController.text)).id == "NONE")
      return false;
    else
      return true;
  }
  
  void onResetPasswordButtonPressed(BuildContext context) async {
    var currentUser = await Student.getStudentByID(studentIDTextController.text);
    if(currentUser.id == "NONE") {
      setState(() {
        loginInfo = "未找到用户";
      });
    } else {
      if(currentUser.email == "NONE") {
        setState(() {
          loginInfo = "未设置邮箱，请联系班主任重置密码";
        });
      } else {
        await DatabaseHelper.leanCloudResetPassword(currentUser.email);
        setState(() {
          loginInfo = "重置邮件已发送";
        });
      }
    }
    if(mounted) {
      setState(() {
        enableLoginButton = true;
      });
    }
  }

  void onLoginButtonPressed(BuildContext context, bool ignorePassword) async {
    if (agreePrivacy == false) {
      setState(() {
        loginInfo = "请同意《隐私策略》后，在进行登录";
      });
    }
    else {
      var loginStatus = false;
      if (ignorePassword == true) {
        if (ApplicationHelper.useBiometrics == true) {
          loginStatus = await ApplicationHelper.checkBiometrics();
        } else {
          loginStatus = true;
        }
      } else {
        loginStatus = await DatabaseHelper.leanCloudLogin(
            studentIDTextController.text, passwordTextController.text);
      }
      if (loginStatus == false) {
        loginerrorcount += 1;
        setState(() {
          if (loginerrorcount >= 6) {
            loginInfo = "错误次数太多，请30分钟之后再试";
          } else {
            loginInfo = "用户名或密码错误";
          }
        });
      }
      else {
        setState(() {
          loginInfo = "正在获取用户信息";
        });
        var currentUser = await Student.getStudentByID(
            studentIDTextController.text);
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
        await ApplicationHelper.setLocalDatabaseString(
            "id", ApplicationHelper.currentUser.id);
        setState(() {
          Navigator.pushAndRemoveUntil(
            context,
            new MaterialPageRoute(builder: (context) =>
            new MaterialApp(
                home: new ScheduleViewWidget())),
                (route) => route == null,
          );
        });
      }
    }
    if (mounted) {
      setState(() {
        enableLoginButton = true;
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
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: SizedBox(
                  width: 256,
                  child: TextField(
                    controller: studentIDTextController,
                    decoration: InputDecoration(
                      hintText: "学号",
                      border: UnderlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: AppColors.NormalInputText,
                      fontFamily: FontsHelper.DefaultTextFontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: FontsHelper.DefaultInputTextFontSize,
                    ),
                    onEditingComplete: () {
                      setState(() {
                        FocusScope.of(context).requestFocus(FocusNode());
                      });
                    },
                  ),
                ),
              ),
            ),
            Padding(
            padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
            child: SizedBox(
              width: 256,
              child: TextField(
                obscureText: true,
                controller: passwordTextController,
                decoration: InputDecoration(
                  hintText: "密码",
                  border: UnderlineInputBorder(),
                ),
                style: TextStyle(
                  color: AppColors.NormalInputText,
                  fontFamily: FontsHelper.DefaultTextFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: FontsHelper.DefaultInputTextFontSize,
                ),
                onEditingComplete: () {
                  setState(() {
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              ),
            ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(32, 32, 32, 8),
              child: SizedBox(
                width: 256,
                child: ImageButton(
                  height: enableLoginButton == true ? 40 : 0,
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
                    setState(() {
                      enableLoginButton = false;
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                    this.onLoginButtonPressed(context, false);
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: SizedBox(
                width: enableLoginButton == true ? 256 : 0,
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Text("注册账号"),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            CupertinoAlertDialog (
                              title: Text("注册提示"),
                              content: Text("请联系班主任进行注册"),
                              actions: <Widget>[
                                FlatButton(
                                  child: new Text("确定"),
                                  onPressed: () {
                                    FocusScope.of(context).requestFocus(FocusNode());
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                      ),
                    ),
                    Expanded(child: Container(),),
                    FlatButton(
                      child: Text("忘记密码？"),
                      onPressed: (){
                        setState(() {
                          enableLoginButton = false;
                        });
                        FocusScope.of(context).requestFocus(FocusNode());
                        this.onResetPasswordButtonPressed(context);},
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: SizedBox(
                width: enableLoginButton == true ? 256 : 0,
                child: Row(
                  children: <Widget>[
                    Expanded(child: Container(),),
                    Checkbox(value: agreePrivacy, onChanged: (value) => setState(() {
                      agreePrivacy = value;
                    })),
                    Text("同意"),
                    InkWell(
                      child: Text("《隐私策略》",
                      style: TextStyle(
                        color: Colors.blue
                      ),
                      ),
                      onTap: () async => await launch("https://blog.csdn.net/qq_27485675/article/details/104864866"),
                    )
                  ],
                ),
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