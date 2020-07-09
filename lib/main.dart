import 'package:barbart/constants.dart';
import 'package:flutter/material.dart';

import 'pages/home/homepage.dart';
import 'mainscreen.dart';
import 'pages/music/musicpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Barb'Art",
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: MainScreen()

    );
  }
}