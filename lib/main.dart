import 'package:barbart/api/APIValues.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/screens/profile/loginscreen.dart';
import 'package:barbart/screens/profile/profilescreen.dart';
import 'package:barbart/screens/profile/signupscreen.dart';
import 'package:barbart/screens/serversplashscreen.dart';
import 'package:barbart/screens/settings/settingsscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api/APIManager.dart';
import 'components/mainbody.dart';
import 'pages/home/homepage.dart';
import 'screens/mainscreen.dart';
import 'pages/music/musicpage.dart';

// Disgusting global variable but should be accessible from everywhere, that's what gvar are for.. .
// Naming convention : global variables starts with 'g'
APIValues gAPI;

Future<void> main() async {

  /* Initiating API */
  gAPI = new APIValues(config: new APIConfig(
      forceRequests: false,
      postsBeginTime: DateTime(1999), // From 1999-01-01 00:00:00
      postsEndTime: DateTime.now().add(Duration(days: 1)) // To tomorrow to have every posts
  ));

  WidgetsFlutterBinding.ensureInitialized();

  // Attempting to load from config file.
  await gAPI.load();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Barb'Art",
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      routes: {
        '/' : (context) => MainScreen(),
        '/MainBody' : (context) => MainBody(),
        '/profile'  : (context) => ProfileScreen(),
        '/login'    : (context) => LoginScreen(),
        '/signup'   : (context) => SignupScreen(),
        '/settings' : (context) => SettingsScreen(),
      },

    );
  }
}