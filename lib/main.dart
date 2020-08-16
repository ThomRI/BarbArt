import 'package:barbart/api/APIValues.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/screens/settings/settingsscreen.dart';
import 'package:flutter/material.dart';

import 'api/APIManager.dart';
import 'pages/home/homepage.dart';
import 'screens/mainscreen.dart';
import 'pages/music/musicpage.dart';

// Disgusting global variable but should be accessible from everywhere, that's what gvar are for.. .
// Naming convention : global variables starts with 'g'
APIValues gAPI;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Barb'Art",
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      routes: {
        '/' : (context) => MainScreen(),
        '/settings' : (context) => SettingsScreen(),
      },

    );
  }
}