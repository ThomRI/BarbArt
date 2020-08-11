import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

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

DateTime extractDate(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

String timeToString(DateTime time) {
  return  ((time.hour < 10) ? "0" : "") + time.hour.toString() + 'h' + ((time.minute < 10) ? "0" : "") + (time.minute.toString() ?? "");
}