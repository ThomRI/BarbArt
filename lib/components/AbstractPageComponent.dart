import 'package:barbart/constants.dart';
import 'file:///C:/Users/chpau/AndroidStudioProjects/BarbArtv2/lib/pages/data.dart';
import 'package:flutter/cupertino.dart';

abstract class AbstractPageComponent {
  String get name;
  Icon get icon;
  dynamic get logo;

  static Color backgroundColor = background_color;
}