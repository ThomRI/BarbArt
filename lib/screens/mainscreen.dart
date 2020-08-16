import 'package:barbart/api/APIValues.dart';
import 'package:barbart/components/animated/PulsatingImage.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/pages/home/homepage.dart';
import 'package:barbart/screens/profile/loginscreen.dart';
import 'package:barbart/screens/serversplashscreen.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/mainbody.dart';
import '../main.dart';

class MainScreen extends StatefulWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        //appBar: _buildAppBar(),
        body: LoginScreen(),
      ),
    );
  }
}