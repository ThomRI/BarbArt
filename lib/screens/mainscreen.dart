import 'package:barbart/api/APIValues.dart';
import 'package:barbart/components/animated/PulsatingImage.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/pages/home/homepage.dart';
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
  bool _pending = true; // Currently waiting for the server


  @override
  void initState() {
    super.initState();

    /* Updating API */
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
          gAPI.update(APIFlags.EVENTS | APIFlags.PROFILE | APIFlags.SOCIAL_POSTS | APIFlags.MUSIC_RESERVATIONS, onUpdateDone: () {
            gAPI.save();

            this.setState(() {
              _pending = false;
            });
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        //appBar: _buildAppBar(),
        body: _pending ? Container(
          width: deviceSize(context).width,
          height: deviceSize(context).height,
          color: kPrimaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
             PulsatingImage(
               image: AssetImage("assets/logo_clipped_sd.png"),
               beginSize: dp(context, 60),
               endSize: dp(context, 80),
               milliseconds: 400,
             ),
            ],
          )
        ) : MainBody(),
      ),
    );
  }
}