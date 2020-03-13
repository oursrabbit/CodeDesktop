import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:sign/Model/room.dart';
import 'package:sign/Model/course.dart';
import 'package:sign/Model/professor.dart';
import 'package:sign/Model/room.dart';
import 'package:sign/Model/schedule.dart';
import 'package:sign/applicationhelper.dart';
import 'package:sign/main.dart';
import 'package:sign/roomlistviewwidget.dart';
import 'package:sign/values/colors.dart';
import 'package:sign/values/fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Model/section.dart';
import 'facedetectviewwidget.dart';

class RoomListViewViewWidget extends StatefulWidget {
  RoomListViewViewWidget({Key key}) : super(key: key);

  @override
  _RoomListViewViewWidget createState() => _RoomListViewViewWidget();
}

class _RoomListViewViewWidget extends State<RoomListViewViewWidget> {
  ScrollController _dayCalendarController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _dayCalendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget secondPart;
    /*if (rooms == null) {
      secondPart = Container(
        //color: Colors.red,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              '正在加载数据...',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                color: AppColors.PrimaryBackground,
                fontFamily: FontsHelper.NormalTextFontFamily,
                fontSize: FontsHelper.NormalTextFontSize,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      );
    }*/
    //else {
    secondPart = Container(
      child: ListView.builder(
          itemCount: ApplicationHelper.checkBuilding.getRooms().length,
          itemExtent: 64,
          //controller: _monthCalendarController,
          itemBuilder: (BuildContext context, int index) {
            return createRoomCell(index);
          }
      ),
    );
    //}

    return Scaffold(
      body: Container(
        color: AppColors.AppDefaultBackgroundColor,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(32, 32, 0, 0),
                child: Stack(
                  alignment: Alignment.topLeft,
                  children: <Widget>[
                    Row(children: <Widget>[
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
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(32, 8, 0, 0),
                child: Container(
                  width: double.infinity,
                  child: Stack(
                    children: <Widget>[
                      Text(
                        '请选择签到地点',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.PrimaryBackground.withAlpha(127),
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(padding: EdgeInsets.fromLTRB(32, 16, 32, 0),
                  child: secondPart,),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createRoomCell(int cellIndex) {
    Room room = ApplicationHelper.checkBuilding.getRooms()[cellIndex];
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: Text("准备签到"),
                content: Text("请确认已经抵达教室\n${"(" + room.getLocation().name + ")" +
                    room.name}"),
                actions: <Widget>[
                  FlatButton(
                    child: new Text("取消"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  FlatButton(
                    child: new Text("开始签到"),
                    onPressed: () {
                      ApplicationHelper.checkRoom = room;
                      Navigator.of(context).pop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        new MaterialPageRoute(builder: (context) => new MaterialApp(home: new FaceDetectViewWidget())),
                            (route) => route == null,
                      );
                    },
                  ),
                ],
              ),
        );
      },
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Container(
          //color: Colors.red,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(5, 9, 8, 0),
                child: Container(
                  width: double.infinity,
                  //color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    '${room.name}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.PrimaryBackground,
                      fontFamily: FontsHelper.DefaultTextFontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}