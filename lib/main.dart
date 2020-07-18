import 'package:barbart/constants.dart';
import 'package:barbart/screens/settings/settingsscreen.dart';
import 'package:barbart/screens/profile/profileScreen.dart';
import 'package:flutter/material.dart';

import 'pages/home/homepage.dart';
import 'screens/mainscreen.dart';
import 'pages/music/musicpage.dart';

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
        '/profile' : (context) => ProfileScreen(),
      },

    );
  }
}