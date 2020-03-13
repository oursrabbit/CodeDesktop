import 'package:date_util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:qinflutter/Model/building.dart';
import 'package:qinflutter/Model/checklog.dart';
import 'package:qinflutter/Model/course.dart';
import 'package:qinflutter/Model/professor.dart';
import 'package:qinflutter/Model/room.dart';
import 'package:qinflutter/Model/schedule.dart';
import 'package:qinflutter/applicationhelper.dart';
import 'package:qinflutter/main.dart';
import 'package:qinflutter/values/colors.dart';
import 'package:qinflutter/values/fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Model/section.dart';

class HistoryViewViewWidget extends StatefulWidget {
  HistoryViewViewWidget({Key key}) : super(key: key);

  @override
  _HistoryViewViewWidget createState() => _HistoryViewViewWidget();
}

class _HistoryViewViewWidget extends State<HistoryViewViewWidget> {
  List<CheckLog> history = null;
  List<CheckLog> drawhistory = null;
  ScrollController _historyListController = ScrollController();
  TextEditingController controller = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDate();
  }

  @override
  void dispose() {
    _historyListController.dispose();
    super.dispose();
  }

  getDate() async {
    var result = await CheckLog.getAllCheckLogs();
    setState(() {
      history = result;
      drawhistory = result;
    });
  }

  void onSearch() {
    FocusScope.of(context).requestFocus(FocusNode());
    if(controller.text.isEmpty){
      setState(() {
        drawhistory = history;
      });
    } else {
      var dh = List<CheckLog>();
      for(var h in history){
        if(h.isIncludeKeyword(controller.text))
          dh.add(h);
      }
      setState(() {
        drawhistory = dh;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget secondPart;
    if(drawhistory == null) {
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
    }
    else {
      secondPart = Container(
        child: ListView.builder(
            itemCount: drawhistory.length,
            itemExtent: 93,
            //controller: _monthCalendarController,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(32, 0, 32, 16),
                child: createCheckLogCell(index),
              );
            }
        ),
      );
    }

    return Scaffold(
      body: Container(
        color: AppColors.AppDefaultBackgroundColor,
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
            Stack(
              children: <Widget>[
                Text(
                  '${ApplicationHelper.currentUser.name} · 签到记录',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.PrimaryBackground,
                    fontFamily: FontsHelper.DefaultTextFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: FontsHelper.DefaultButtonTextFontSize,
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
              child: createSearchBar(),
            ),
            Expanded(
              child: secondPart,
            ),
          ],
        ),
      ),
    );
  }

  Widget createCheckLogCell(int cellIndex) {
    CheckLog checkLog = drawhistory[cellIndex];
    var diff = DateTime.now().difference(checkLog.checkDate);
    var diffString = "";
    if(diff.inDays != 0){ diffString = "${diff.inDays}天前";}
    else if(diff.inHours != 0){ diffString = "${diff.inHours}小时前";}
    else if(diff.inMinutes != 0){diffString = "${diff.inMinutes}分前"; }
    else{diffString = "刚刚";}
    var checkRoom = Room.allRooms.firstWhere((t) => t.id == checkLog.checkRoomID, orElse: () => new Room());
    var checkBuilding = checkRoom.getLocation();
    return Card(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Container(
        //color: Colors.green,
        constraints: BoxConstraints.expand(),
        child: Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(8, 8, 0, 0),
              child: Container(
                height: double.infinity,
                width: 45,
                //color: Colors.red,
                alignment: Alignment.topCenter,
                child: Image.asset('assets/images/defaultroomiconimage.png'),
              ),
            ),
            Expanded(child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 9, 8, 0),
                  child: Container(
                    height: 15,
                    width: double.infinity,
                    //color: Colors.red,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '签到地点：${ checkBuilding.name + checkRoom.name}',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.PrimaryBackground,
                        fontFamily: FontsHelper.DefaultTextFontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(5, 10, 8, 0),
                  child: Container(
                    //color: Colors.red,
                    height: 15,
                    width: double.infinity,
                    //color: Colors.yellow,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '签到时间：${drawhistory[cellIndex].checkDate.convertToString('yyyy年MM月dd日 HH:mm:ss')}',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.PrimaryBackground,
                        fontFamily: FontsHelper.DefaultTextFontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 3, 8, 0),
                  child: Container(
                    height: 15,
                    width: double.infinity,
                    //color: Colors.blue,
                    alignment: Alignment.centerRight,
                    child: Text(
                      diffString,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.black.withAlpha(51),
                        fontFamily: FontsHelper.DefaultTextFontFamily,
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),)
          ],
        ),
      ),
    );
  }

  Widget createSearchBar() {
    return Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(45.0))),
        child: new Container(
          height: 25,
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(width: 15.0,),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: TextField(
                    style: TextStyle(
                      color: AppColors.PrimaryBackground,
                      fontFamily: FontsHelper.DefaultTextFontFamily,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    controller: controller,
                    decoration: new InputDecoration(
                        hintText: 'Search', border: InputBorder.none),
                    onSubmitted: (_) => onSearch(),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}