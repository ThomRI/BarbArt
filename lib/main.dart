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

  MyApp() {
    gAPI = new APIValues(config: new APIConfig(
      forceRequests: false,
      postsBeginTime: DateTime(1999), // From 1999-01-01 00:00:00
      postsEndTime: DateTime.now().add(Duration(days: 1)) // To tomorrow to have every posts
    ));

    /* API Authentication */
    print("Attempting to auth...");
    gAPI.authenticate(
        email: "claire.betbeder@imt-atlantique.net",
        password: "MyPass",
        onAuthenticated: () {
          print("Authenticated, uuid: " + gAPI.selfClient.uuid);
          gAPI.update(APIFlags.EVENTS | APIFlags.PROFILE | APIFlags.SOCIAL_POSTS, onUpdateDone: () {
            gAPI.save();
          });
        }
    );
  }

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