import 'package:barbart/constants.dart';
import 'package:barbart/screens/settings/settingsscreen.dart';
import 'package:barbart/screens/profile/profileScreen.dart';
import 'package:barbart/screens/login/loginscreen.dart';
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
      initialRoute: '/login',
      routes: {
        '/home' : (context) => MainScreen(),
        '/settings' : (context) => SettingsScreen(),
        '/login' : (context) => LoginScreen(),
        '/profile' : (context) => ProfileScreen(),
      },

    );
  }
}