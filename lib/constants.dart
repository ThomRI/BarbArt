import 'package:flutter/material.dart';

//const kBackgroundColor = const Color(0xFF072d25);
final Color kBackgroundColor = Colors.grey[200];
const kPrimaryColor = const Color(0xFF0e5847);

const kDefaultNotifierDuration = Duration(milliseconds: 300);

const kDefaultPadding = 20.0;
const kDefaultRadius = 30.0;
const kDefaultCurveShift = 15.0;

const kDefaultTransitionDuration = const Duration(milliseconds: 100);

const double kLogoSize = 135;

/* API */
const API_BASEHOST = "192.168.43.203";
const API_PORT = 3000;
String API_BASEURL = "http://" + API_BASEHOST + ":" + API_PORT.toString();
String API_WS_BASEURL = "ws://" + API_BASEHOST + ":" + API_PORT.toString();
const API_SAVEFILE = "api.json";