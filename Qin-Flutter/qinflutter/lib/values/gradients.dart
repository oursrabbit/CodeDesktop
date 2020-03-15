/*
*  gradients.dart
*  qin
*
*  Created by CY.
*  Copyright © 2018 edu.bfa.sa. All rights reserved.
    */

import 'package:flutter/rendering.dart';


class Gradients {
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment(2.29584, -0.09614),
    end: Alignment(-0.24951, -0.04118),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 102, 129, 132),
      Color.fromARGB(255, 45, 87, 91),
    ],
  );
  static const Gradient secondaryGradient = LinearGradient(
    begin: Alignment(0.5, -0.21388),
    end: Alignment(0.5, 1.10814),
    stops: [
      0,
      1,
    ],
    colors: [
      Color.fromARGB(255, 27, 77, 81),
      Color.fromARGB(255, 29, 61, 64),
    ],
  );
}