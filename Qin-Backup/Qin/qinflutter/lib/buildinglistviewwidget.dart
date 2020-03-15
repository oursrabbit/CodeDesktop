import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:sign/Model/building.dart';
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

class BuildingListViewViewWidget extends StatefulWidget {
  BuildingListViewViewWidget({Key key}) : super(key: key);

  @override
  _BuildingListViewViewWidget createState() => _BuildingListViewViewWidget();
}

class _BuildingListViewViewWidget extends State<BuildingListViewViewWidget> {
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
    /*if (buildings == null) {
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
    var cellWidth = (MediaQuery
        .of(context)
        .size
        .width - 64 - 8) / 2.0;
    cellWidth = cellWidth > 147 ? 147 : cellWidth;
    //cellWidth = 100;
    secondPart = Container(
      child: GridView.builder(
          itemCount: Building.allBuildings.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: cellWidth,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1,
          ),
          //controller: _monthCalendarController,
          itemBuilder: (BuildContext context, int index) {
            return createBuildingWidget(index);
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
                        '你好，${ApplicationHelper.currentUser.name}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppColors.PrimaryBackground,
                          fontFamily: FontsHelper.DefaultTextFontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: 30,
                        ),
                      ),
                    ],
                  ),
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

  Widget createBuildingWidget(int cellIndex) {
    Building building = Building.allBuildings[cellIndex];
    return GestureDetector(
      onTap: () {
        ApplicationHelper.checkBuilding = building;
        Navigator.push(context, MaterialPageRoute(builder: (context) {return RoomListViewViewWidget();}));
      },
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Container(
          //color: Colors.red,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                child: Container(
                  height: 40,
                  width: 40,
                  //color: Colors.red,
                  alignment: Alignment.topCenter,
                  child: Image.asset('assets/images/defaultroomiconimage.png'),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(5, 9, 8, 0),
                child: Container(
                  width: double.infinity,
                  //color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    '${building.name}',
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
              /*Padding(
                padding: EdgeInsets.fromLTRB(5, 9, 8, 0),
                child: Container(
                  width: double.infinity,
                  //color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    '${building.getRooms().length} 间房间',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.PrimaryBackground.withAlpha(127),
                      fontFamily: FontsHelper.DefaultTextFontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}