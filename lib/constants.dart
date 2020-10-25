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

/* Music registrations constants */
const kDaysIntervalRegistrationAllowed = 14; // 2 weeks allowed to register

/* Header constants */
const double HEADER_HEIGHT_SCREEN_RATIO = 0.3;

/* Math constants */
const double MS_IN_ONE_DAY = 86400000.0;

/* Events page constants */
DateTime kEventsMinimumDateTime = DateTime.now().subtract(Duration(days: 7));
DateTime kEventsMaximumDateTime = DateTime.now().add(Duration(days: 7));

/* API */
const API_BASEHOST = "barbart.herokuapp.com";
const API_PORT = 443;
String API_BASEURL = "https://" + API_BASEHOST + ":" + API_PORT.toString();
String API_WS_BASEURL = "ws://" + API_BASEHOST + ":" + API_PORT.toString();

const API_SAVEFILE = "api.json";
const API_TOKEN_SAVEFILE = "token.api.json";