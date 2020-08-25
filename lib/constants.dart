import 'package:barbart/utils.dart';
import 'package:flutter/material.dart';

//const kBackgroundColor = const Color(0xFF072d25);
final Color kBackgroundColor = Colors.grey[200];
const kPrimaryColor = const Color(0xFF0e5847);
final Color kDefaultCircleAvatarBackgroundColor = Colors.grey[400];

const kDefaultNotifierDuration = Duration(milliseconds: 300);

double kDefaultButtonWidthRatio = 0.75; // Portion of the width screen for the buttons

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
const API_TOKEN_SAVEFILE = "token.api.json";