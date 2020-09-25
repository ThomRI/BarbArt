import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

import 'api/structures.dart';

double dp(BuildContext context, double pixels) {
  return MediaQuery.of(context).devicePixelRatio * pixels;
}

Size deviceSize(BuildContext context) {
  return MediaQuery.of(context).size;
}

Orientation deviceOrientation(BuildContext context) {
  return MediaQuery.of(context).orientation;
}

Future<String> get appLocalPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}


/* DateTime utils */
DateTime extractDate(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

bool sameDates(DateTime a, DateTime b) {
  return extractDate(a) == extractDate(b);
}

String timeToString(DateTime time) {
  return  ((time.hour < 10) ? "0" : "") + time.hour.toString() + 'h' + ((time.minute < 10) ? "0" : "") + (time.minute.toString() ?? "");
}

String ago(DateTime when) {
  Duration delta = DateTime.now().difference(when);

  if(delta.inMinutes >= 1) {
    if(delta.inHours >= 1) {
      if(delta.inDays >= 1) return delta.inDays.toString() + " day" + ((delta.inDays > 1) ? "s" : "");

      return delta.inHours.toString() + " hour" + ((delta.inHours > 1) ? "s" : "");
    }

    return delta.inMinutes.toString() + " minute" + ((delta.inMinutes > 1) ? "s" : "");
  }

  return delta.inSeconds.toString() + " second" + ((delta.inSeconds > 1) ? "s" : "");
}

DateTime changeDate(DateTime from, DateTime date) {
  return DateTime(date.year, date.month, date.day, from.hour, from.minute, from.second, from.millisecond, from.microsecond);
}

bool isThisWeek(DateTime date) {
  DateTime extracted = extractDate(date);
  DateTime today = extractDate(DateTime.now());

  return extracted.compareTo(today.add(Duration(days: 7))) < 0 && extracted.compareTo(today) >= 0
          && extracted.weekday >= today.weekday;
}