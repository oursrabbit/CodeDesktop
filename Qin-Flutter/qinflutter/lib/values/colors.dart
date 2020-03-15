/*
*  colors.dart
*  qin
*
*  Created by CY.
*  Copyright © 2018 edu.bfa.sa. All rights reserved.
    */

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AppColors {
  static const Color PrimaryBackground = Color.fromARGB(255, 45, 87, 91);
  static const Color primaryElement = Color.fromARGB(255, 246, 247, 249);
  static const Color primaryText = Color.fromARGB(255, 0, 0, 0);
  static const Color secondaryText = Color.fromARGB(255, 37, 56, 88);
  static const Color accentText = Color.fromARGB(255, 45, 87, 91);

  static const Color PrimaryColor = Color.fromARGB(255, 101, 129, 131);

  static const Color AppDefaultBackgroundColor = Color.fromARGB(
      255, 229, 229, 229);

  static const Color NormalText = Color.fromARGB(255, 255, 255, 255);
  static const Color NormalInputText = Color.fromARGB(255, 0, 0, 0);

  static const Color TimeLine = Color.fromARGB(255, 216, 216, 216);
  static const Color TimeText = Color.fromARGB(153, 39, 53, 83);

  static const List<Color> ScheduleDecorateCellColors = [
    Color.fromARGB(255, 55, 67, 101),
    Color.fromARGB(255, 117, 133, 178),
    Color.fromARGB(255, 107, 167, 173),
    Color.fromARGB(255, 150, 109, 73),
  ];

  static const List<Color> ScheduleCellColors = [
    Color.fromARGB(38, 55, 67, 101),
    Color.fromARGB(38, 55, 67, 101),
    Color.fromARGB(38, 107, 167, 173),
    Color.fromARGB(38, 150, 109, 73),
  ];

  static const List<Color> ScheduleTextCellColors = [
    Color.fromARGB(255, 241, 99, 19),
    Color.fromARGB(255, 13, 89, 60),
    Color.fromARGB(255, 36, 61, 111),
    Color.fromARGB(255, 105, 40, 212),
  ];
}