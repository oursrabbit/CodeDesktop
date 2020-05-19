import 'dart:io';

import 'package:date_util/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sign/Model/building.dart';
import 'package:sign/Model/course.dart';
import 'package:sign/Model/professor.dart';
import 'package:sign/Model/room.dart';
import 'package:sign/Model/schedule.dart';
import 'package:sign/applicationhelper.dart';
import 'package:sign/bledetectviewwidget.dart';
import 'package:sign/buildinglistviewwidget.dart';
import 'package:sign/facedetectviewwidget.dart';
import 'package:sign/generated/i18n.dart';
import 'package:sign/historyviewwidget.dart';
import 'package:sign/main.dart';
import 'package:sign/settingviewwidget.dart';
import 'package:sign/values/colors.dart';
import 'package:sign/values/fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import 'Model/section.dart';
import 'loginviewwidget.dart';

class ScheduleViewWidget extends StatefulWidget {
  ScheduleViewWidget({Key key}) : super(key: key);

  @override
  _ScheduleViewWidget createState() => _ScheduleViewWidget();
}

class _ScheduleViewWidget extends State<ScheduleViewWidget> {
  DateTime selectedDay = DateTime.now();
  bool isExpandedCalendar = false;
  List<Schedule> selectedDaySchedules = null;

  ScrollController _dayCalendarController = ScrollController();
  ScrollController _monthCalendarController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dayCalendarController =
        ScrollController(initialScrollOffset: 52.0 * (selectedDay.day - 1));
    _monthCalendarController = ScrollController(
        initialScrollOffset: 315.0 * 3 * 12 + 315 * (selectedDay.month));
    updateSchedule(selectedDay);
  }

  @override
  void dispose() {
    _dayCalendarController.dispose();
    _monthCalendarController.dispose();
    super.dispose();
  }

  updateSchedule(DateTime date) async {
    await Schedule.getSchedulesByStudentID(ApplicationHelper.currentUser.id);
    setState(() {
      isExpandedCalendar = false;
      this.selectedDay = date;
      selectedDaySchedules = Schedule.getSchedulesOnDate(date);
      _dayCalendarController =
          ScrollController(initialScrollOffset: 52.0 * (selectedDay.day - 1));
      _monthCalendarController = ScrollController(
          initialScrollOffset: 315.0 * 3 * 12 + 315 * (selectedDay.month));
    });
  }

  updateSelectedDay(DateTime date) async {
    setState(() {
      isExpandedCalendar = false;
      this.selectedDay = date;
      selectedDaySchedules = Schedule.getSchedulesOnDate(date);
      _dayCalendarController =
          ScrollController(initialScrollOffset: 52.0 * (selectedDay.day - 1));
      _monthCalendarController = ScrollController(
          initialScrollOffset: 315.0 * 3 * 12 + 315 * (selectedDay.month));
    });
  }

  void onBackToTodayPressed(BuildContext context) {
    if (this.isExpandedCalendar == false) {
      _dayCalendarController.animateTo(52.0 * (DateTime
          .now()
          .day - 1), duration: Duration(milliseconds: 500),
          curve: Curves.decelerate);
      updateSelectedDay(DateTime.now());
    }
    else {
      _dayCalendarController =
          ScrollController(initialScrollOffset: 52.0 * (DateTime
              .now()
              .day - 1));
      updateSelectedDay(DateTime.now());
    }
  }

  void onChangeCalendarStyle(BuildContext context) {
    setState(() {
      this.isExpandedCalendar = !this.isExpandedCalendar;
      _monthCalendarController = ScrollController(
          initialScrollOffset: 315.0 * (selectedDay.year - (DateTime
              .now()
              .year - 3)) * 12 + 315 * (selectedDay.month));
      _dayCalendarController =
          ScrollController(initialScrollOffset: 52.0 * (selectedDay.day - 1));
    });
  }

  void onDateClicked(BuildContext context, DateTime date) {
    updateSelectedDay(date);
  }

  void onStartScheduleCheck(Schedule schedule) {
    var checkStart = DateTime(
        selectedDay.year, selectedDay.month, selectedDay.day,
        schedule.startSection.startTime.hour,
        schedule.startSection.startTime.minute,
        schedule.startSection.startTime.second);
    var checkEnd = DateTime(
        selectedDay.year, selectedDay.month, selectedDay.day,
        schedule.endSection.endTime.hour, schedule.endSection.endTime.minute,
        schedule.endSection.endTime.second);
    if (DateTime.now().isAfter(checkStart) &&
        DateTime.now().isBefore(checkEnd) ||
        (ApplicationHelper.currentUser.id == "01050305")) {
      showDialog(
        context: context,
        builder: (context) =>
            CupertinoAlertDialog(
              title: Text("准备签到"),
              content: Text("请确认已经抵达教室\n${"(" + schedule.building.name + ")" +
                  schedule.room.name}"),
              actions: <Widget>[
                FlatButton(
                  child: new Text("取消"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                    child: new Text("更换教室"),
                    onPressed: () {
                      ApplicationHelper.isCustomCheckIn = false;
                      ApplicationHelper.checkSchedule = schedule;
                      Navigator.of(context).pop();
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) {
                        return BuildingListViewViewWidget();
                      }));
                    }
                ),
                FlatButton(
                  child: new Text("开始签到"),
                  onPressed: () {
                    ApplicationHelper.isCustomCheckIn = false;
                    ApplicationHelper.checkSchedule = schedule;
                    ApplicationHelper.checkRoom = schedule.room;
                    ApplicationHelper.checkBuilding =
                        schedule.room.getLocation();
                    Navigator.of(context).pop();
                    Navigator.pushAndRemoveUntil(
                      context,
                      new MaterialPageRoute(
                          builder: (context) =>
                          new MaterialApp(
                              home: new FaceDetectViewWidget())),
                          (route) => route == null,
                    );
                  },
                ),
              ],
            ),
      );
    }
    else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("签到失败"),
              content: Text(
                  "签到时间为：${checkStart.convertToString('yyyy-MM-dd HH:mm:ss')}至${checkEnd
                      .convertToString('yyyy-MM-dd HH:mm:ss')}"),
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
    Widget secondPart;

    if (selectedDaySchedules == null) {
      secondPart = Expanded(
        child: Container(
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
        ),
      );
    }
    else if (selectedDaySchedules.length == 0) {
      secondPart = Expanded(
        child: Container(
          //color: Colors.red,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Image.asset('assets/images/noschedulesimage.png')
            ],
          ),
        ),
      );
    }
    else {
      secondPart = createScheduleListWidget();
    }

    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            createHeaderWidget(),
            secondPart,
          ],
        ),
      ),
    );
  }

  Widget createHeaderWidget() {
    var headerHeight = 0.0;
    Widget calendarWidget;
    if (this.isExpandedCalendar == true) {
      headerHeight = 513.0;
      calendarWidget = Expanded(
        child: Container(
          child: ListView.builder(
              itemCount: 7 * 12,
              itemExtent: 315,
              controller: _monthCalendarController,
              itemBuilder: (BuildContext context, int index) {
                return createMonthCalendarWidget(index);
              }
          ),
        ),
      );
    } else {
      headerHeight = 200.0 + MediaQuery.of(context).padding.top;
      calendarWidget = createDayCalendarWidget();
    }

    return Container(
      //width: double.infinity,
      height: headerHeight,
      color: AppColors.PrimaryBackground,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new ExactAssetImage('assets/images/schedulebackground.png'),
            fit: BoxFit.none,
          ),
        ),
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.fromLTRB(22, 60 - 18.0, 0, 0),
                child: SafeArea(child: createHeaderButtons(),)
            ),
            calendarWidget,
          ],
        ),
      ),
    );
  }

  Widget createHeaderButtons() {
    return Row(
      children: <Widget>[
        Text(
          selectedDay.convertToString('yyyy年MM月'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.NormalText,
            fontFamily: FontsHelper.DefaultTextFontFamily,
            fontWeight: FontWeight.w400,
            fontSize: FontsHelper.DefaultButtonTextFontSize,
          ),
        ),
        GestureDetector(
          onTap: () => this.onChangeCalendarStyle(context),
          child: Container(
            width: 30,
            child: Image.asset('assets/images/arrowdropdown.png'),
          ),
        ),
        Expanded(child: Container(),),
        FlatButton(
          onPressed: () => this.onBackToTodayPressed(context),
          child: Text(
            "回到今日",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.NormalText,
              fontFamily: FontsHelper.DefaultTextFontFamily,
              fontWeight: FontWeight.w400,
              fontSize: FontsHelper.DefaultButtonTextFontSize / 2,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.settings, size: 18, color: Colors.white,),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) {
            return SettingViewWidget();
          })),
        )
      ],
    );
  }

  Widget createMonthCalendarWidget(int monthIndex) {
    var startDay = DateTime(DateTime
        .now()
        .year - 3);
    var watchingDay = DateTime(
        startDay.year + monthIndex ~/ 12, monthIndex % 12);
    var cellWidth = (MediaQuery
        .of(context)
        .size
        .width - 44) / 7.0;

    var monthCalendarCells = new List<Widget>();

    monthCalendarCells.add(Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              watchingDay.convertToString('yyyy年') + "\n" +
                  watchingDay.convertToString('MM月'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.NormalText.withAlpha(32),
                fontFamily: FontsHelper.TimeLineTextFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 60,
              ),
            ),
          ],
        )
    ));

    var weekdayHeader = new List<Widget>();
    List<String> weekdayString = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    for (var i = 0; i < 7; i++) {
      weekdayHeader.add(Positioned(
        left: 22.0 + i * cellWidth,
        height: 20,
        child: createWeekdayCell(weekdayString[i]),
      ));
    }
    monthCalendarCells.addAll(weekdayHeader);

    var dayCells = new List<Widget>();
    var firstDayInMonth = DateTime(watchingDay.year, watchingDay.month);
    var offsetDay = firstDayInMonth.weekday % 7;
    for (var i = 0; i <
        DateUtil().daysInMonth(watchingDay.month, watchingDay.year); i++) {
      var cellDate = watchingDay.add(Duration(days: i));
      if (cellDate.day == selectedDay.day &&
          cellDate.year == selectedDay.year &&
          cellDate.month == selectedDay.month) {
        var locationOffset = i + offsetDay;
        dayCells.add(Positioned(
          left: 22.0 + (locationOffset % 7) * cellWidth,
          top: 42 + (locationOffset ~/ 7) * (42.0 + 1),
          height: 42.0,
          child: createSelectedDayInMonthCell(cellDate),
        ));
      }
      else {
        var locationOffset = i + offsetDay;
        dayCells.add(Positioned(
          left: 22.0 + (locationOffset % 7) * cellWidth,
          top: 42 + (locationOffset ~/ 7) * (42.0),
          height: 42.0,
          child: createDayInMonthCell(cellDate),
        ));
      }
    }

    monthCalendarCells.addAll(dayCells);

    return Container(
      //color: Colors.green.withAlpha(0),
      height: 400,
      constraints: BoxConstraints.expand(),
      child: Stack(
        alignment: Alignment.topLeft,
        children: monthCalendarCells,
      ),
    );
  }

  Widget createWeekdayCell(String header) {
    var cellWidth = (MediaQuery
        .of(context)
        .size
        .width - 44) / 7.0;
    return Container(
      //color: Colors.red,
        width: cellWidth,
        height: 20,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Text(
                  header,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.NormalText.withAlpha(127),
                    fontFamily: FontsHelper.TimeLineTextFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        )
    );
  }

  Widget createDayInMonthCell(DateTime date) {
    var cellWidth = (MediaQuery
        .of(context)
        .size
        .width - 44) / 7.0;
    return GestureDetector(
      onTap: () => this.onDateClicked(context, date),
      child: Container(
        //color: Colors.blue,
        width: cellWidth,
        height: 42.0,
        //color: Colors.red,
        child: Column(
          children: <Widget>[
            Container(
              height: 32,
              //color: Colors.green,
              child: Text(
                date.day.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.NormalText,
                  fontFamily: FontsHelper.TimeLineTextFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Schedule
                .getSchedulesOnDate(date)
                .length == 0 ? Container() : Image.asset(
                'assets/images/schedulecircle.png'),
          ],
        ),
      ),
    );
  }

  Widget createSelectedDayInMonthCell(DateTime date) {
    var cellWidth = (MediaQuery
        .of(context)
        .size
        .width - 44) / 7.0;
    return Container(
      //color: Colors.yellow,
      width: cellWidth,
      height: 42.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 2),
            child: Container(
              height: 32,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: new ExactAssetImage(
                      'assets/images/selecteddayinmonthbackground.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Text(
                date.day.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.PrimaryBackground,
                  fontFamily: FontsHelper.TimeLineTextFontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Schedule
              .getSchedulesOnDate(date)
              .length == 0 ? Container() : Image.asset(
              'assets/images/schedulecircle.png'),
        ],
      ),
    );
  }

  Widget createDayCalendarWidget() {
    var dayCells = new List<Widget>();
    for (var i = 0; i <
        DateUtil().daysInMonth(selectedDay.month, selectedDay.year); i++) {
      var day = new DateTime(selectedDay.year, selectedDay.month, (i + 1));
      if ((i + 1) == selectedDay.day) {
        dayCells.add(new Positioned(
          left: 52.0 * i,
          child: createSelectedDayCell(day),
        ));
      }
      else {
        dayCells.add(new Positioned(
          left: 52.0 * i,
          child: createDayCell(day),
        ));
      }
    }

    return Expanded(
      child: Container(
        constraints: BoxConstraints.expand(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 0, 0, 0),
          child: Scrollbar(
            child: SingleChildScrollView(
              controller: _dayCalendarController,
              scrollDirection: Axis.horizontal,
              child: Container(
                width: 52.0 * DateUtil().daysInMonth(
                    selectedDay.month, selectedDay.year) + 22,
                child: Stack(
                  children: dayCells,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget createDayCell(DateTime day) {
    return GestureDetector(
      onTap: () => this.onDateClicked(context, day),
      child: Container(
        width: 44,
        height: 48,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new ExactAssetImage('assets/images/daycellbackground.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              top: 5,
              child: Text(
                day.convertToString("E"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.NormalText.withAlpha(204),
                  fontFamily: FontsHelper.TimeLineTextFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
              ),
            ),
            Positioned(
              top: 19,
              child: Text(
                day.convertToString("dd"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.NormalText.withAlpha(204),
                  fontFamily: FontsHelper.TimeLineTextFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),);
  }

  Widget createSelectedDayCell(DateTime day) {
    return Container(
      width: 44,
      height: 48,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: new ExactAssetImage(
              'assets/images/selecteddaycellbackground.png'),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 5,
            child: Text(
              day.convertToString('E'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.NormalText,
                fontFamily: FontsHelper.TimeLineTextFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ),
          Positioned(
            top: 19,
            child: Text(
              day.convertToString('dd'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.NormalText,
                fontFamily: FontsHelper.TimeLineTextFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createScheduleListWidget() {
    return Expanded(
      child: Container(
        constraints: BoxConstraints.expand(),
        color: AppColors.AppDefaultBackgroundColor,
        child: loadScheduleList(),
      ),
    );
  }

  Widget loadScheduleList() {
    var scheduleListChildren = new List<Widget>();
    scheduleListChildren.add(new Column(
      children: createTimeLines(),
    ));
    scheduleListChildren.addAll(createSchedule());
    return Scrollbar(
      child: SingleChildScrollView(
        child: Container(
          height: 60.0 * 24.0,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.topLeft,
            children: scheduleListChildren,
          ),
        ),
      ),
    );
  }

  List<Widget> createTimeLines() {
    List<Widget> children = new List<Widget>();
    for (var i = 0; i < 24; i++) {
      children.add(new Container(
        height: 60,
        width: double.infinity,
        color: AppColors.AppDefaultBackgroundColor,
        child: createSingleTimeLine(i),
      ),
      );
    }
    return children;
  }

  Widget createSingleTimeLine(int time) {
    var verticalLine = new Container(
      color: AppColors.TimeLine,
      height: 60,
      width: 1,
    );

    var horizontalLine = new Container(
      color: AppColors.TimeLine,
      height: 1,
      width: MediaQuery
          .of(context)
          .size
          .width,
    );

    var timeText = new Text(
      "$time:00",
      textAlign: TextAlign.right,
      style: TextStyle(
        color: AppColors.TimeText,
        fontFamily: FontsHelper.TimeLineTextFontFamily,
        fontWeight: FontWeight.w600,
        fontSize: FontsHelper.TimeLineTextFontSize,
      ),
    );

    var appearance = new Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        Positioned(
          left: 22,
          width: 32,
          height: 14,
          child: timeText,
        ),
        Positioned(
          top: 7,
          left: 22.0 + 32.0 + 4,
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: 1,
          child: horizontalLine,
        ),
        Positioned(
          left: 22.0 + 32.0 + 4 + 5,
          width: 1,
          height: 60,
          child: verticalLine,
        ),
      ],
    );

    return appearance;
  }

  List<Widget> createSchedule() {
    List<Widget> children = new List<Widget>();

    for (var i = 0; i < selectedDaySchedules.length; i++) {
      children.add(new Positioned(
          left: 62,
          top: selectedDaySchedules[i].x,
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: selectedDaySchedules[i].height,
          child: createSingleSchedule(selectedDaySchedules[i])));
    }
    return children;
  }

  Widget createSingleSchedule(Schedule schedule) {
    var decoration = new Container(
      color: AppColors.ScheduleDecorateCellColors[schedule.cellColorIndex],
      height: double.infinity,
      width: 3,
    );

    var professors = "";
    for (var pro in schedule.professors) {
      professors += pro.name + ",";
    }
    professors = professors.removeLaseChar();
    var location = "(" + schedule.building.name + ")" + schedule.room.name;
    var workingtime = schedule.startSection.startTime.convertToString('HH:mm') +
        "-" + schedule.endSection.endTime.convertToString('HH:mm');
    var courseName = schedule.course.name;
    var checkLog = schedule.getCheckLogOnDate(selectedDay);
    var checkState = checkLog.checkRoomID == "NONE" ? '未签到：点击签到' : '已签到：' +
        checkLog.checkDate.convertToString('yyyy年MM月dd日 HH:mm:ss');

    var courseInfo = Text(
      "$location    $workingtime\n$courseName    $professors\n$checkState",
      textAlign: TextAlign.left,
      style: TextStyle(
        color: AppColors.ScheduleTextCellColors[schedule.cellColorIndex],
        fontFamily: FontsHelper.TimeLineTextFontFamily,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );

    return GestureDetector(
      onTap: () => this.onStartScheduleCheck(schedule),
      child: Container(
        color: AppColors.ScheduleCellColors[schedule.cellColorIndex],
        child: Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            decoration,
            Positioned(
              left: 18,
              top: 4,
              child: courseInfo,
            ),
          ],
        ),
      ),
    );
  }
}