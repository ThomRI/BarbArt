import 'package:barbart/constants.dart';
import 'package:barbart/pages/events/data.dart';
import 'package:flutter/cupertino.dart';

abstract class AbstractPageComponent {
  String get name;
  Icon get icon;
  dynamic get logo;

  static Color backgroundColor = background_color;
}