import 'package:flutter/cupertino.dart';

double dp(BuildContext context, double pixels) {
  return MediaQuery.of(context).devicePixelRatio * pixels;
}