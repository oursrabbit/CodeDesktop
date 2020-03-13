import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign/applicationhelper.dart';
import 'package:sign/databasehelper.dart';
import 'package:sign/loginviewwidget.dart';
import 'package:sign/values/colors.dart';
import 'package:sign/values/fonts.dart';
import 'dart:convert';

class InitViewWidget extends StatefulWidget {
  InitViewWidget({Key key}) : super(key: key);

  @override
  _InitViewWidgetState createState() => _InitViewWidgetState();
}

class _InitViewWidgetState extends State<InitViewWidget> {
  String initInfo = "";

  @override
  void initState() {
    super.initState();
    initInfo = "正在查询软件版本...";
    initApplication();
  }

  initApplication() async {
    ApplicationHelper.canCheckBiometrics = await ApplicationHelper.localAuth.canCheckBiometrics;
    ApplicationHelper.useBiometrics = await ApplicationHelper.getLocalDatabaseBool("useBiometrics");
    ApplicationHelper.currentUser.id = await ApplicationHelper.getLocalDatabaseString("id");
    var url = DatabaseHelper.LeancloudAPIBaseURL +
        "/1.1/classes/ApplicationData/5e59e2ec21b47e0081de8189";
    var response = await DatabaseHelper.leanCloudSearch(url);
    sleep(Duration(seconds: 1));
    var data = json.decode(response.body);
    var serverVersion = data["ApplicationVersion"];
    setState(() {
      print(serverVersion);
      if (9 == serverVersion) {
        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => new MaterialApp(home: new LoginViewWidget())),
              (route) => route == null,
        );
      }
      else {
        initInfo = "请更新至最新版：$serverVersion";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: new ExactAssetImage('assets/images/backgroundimage.png'),
          fit: BoxFit.fill,
        ),
      ),
      alignment: Alignment.center,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Positioned(
                    child: Image.asset(
                      "assets/images/launchimage.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                initInfo,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: AppColors.NormalText,
                  fontFamily: FontsHelper.NormalTextFontFamily,
                  fontSize: FontsHelper.NormalTextFontSize,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                "©2020 BFA Sound School",
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: AppColors.NormalText,
                  fontFamily: FontsHelper.NormalTextFontFamily,
                  fontSize: FontsHelper.NormalTextFontSize,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}