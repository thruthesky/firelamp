import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Space {
  // static const double xxs = 4;
  // static const double xs = 8;
  // static const double xsm = 12;
  // static const double sm = 16;
  // static const double md = 24;
  // static const double lg = 32;
  // static const double xl = 40;
  // static const double xxl = 56;
  static const double xxs = kIsWeb ? 2 : 4;
  static const double xs = kIsWeb ? 6 : 8;
  static const double xsm = kIsWeb ? 10 : 12;
  static const double sm = kIsWeb ? 14 : 16;
  static const double md = kIsWeb ? 22 : 24;
  static const double lg = kIsWeb ? 30 : 32;
  static const double xl = kIsWeb ? 38 : 40;
  static const double xxl = kIsWeb ? 54 : 56;

  static double get forumViewPadding => kIsWeb ? 8.0 : 10.0;
}

const stylePostTitle = TextStyle(
  fontSize: 20,
  color: Colors.blueGrey,
  fontWeight: FontWeight.w400,
  // fontFamily: '',
);

const styleHintText = TextStyle(fontSize: Space.xsm, color: Colors.grey);
