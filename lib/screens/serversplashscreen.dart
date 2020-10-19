import 'package:barbart/api/APIValues.dart';
import 'package:barbart/components/animated/PulsatingImage.dart';
import 'package:barbart/components/mainbody.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../main.dart';
import '../utils.dart';

class ServerSplashScreen extends StatefulWidget {
  final String nextPageNamedRoute;

  const ServerSplashScreen({Key key, this.nextPageNamedRoute}) : super(key: key);

  @override
  _ServerSplashScreenState createState() => _ServerSplashScreenState();
}

class _ServerSplashScreenState extends State<ServerSplashScreen> {

  void initAPI({Function onDone}) {
    /* Updating API */

    if(!gAPI.authenticated) {
      print("Internal server error : trying to launch app with failed authentication ! Aborting update and splashing indefinitely.");
      // TODO : Handle auth failed when splash screen launched.
      return;
    }

    /* API Authentication */
    gAPI.update(APIFlags.EVENTS | APIFlags.PROFILE | APIFlags.SOCIAL_POSTS | APIFlags.MUSIC_RESERVATIONS | APIFlags.CLUBS | APIFlags.EVENTS_SELF_GOING, onUpdateDone: () {
      gAPI.save();
      if(onDone != null) onDone();
    });

  }

  @override
  void initState() {
    super.initState();

    this.initAPI(
        onDone: () {
          Navigator.pushReplacementNamed(context, widget.nextPageNamedRoute);
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: deviceSize(context).width,
        height: deviceSize(context).height,
        color: kPrimaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PulsatingImage(
              image: AssetImage("assets/logo_clipped_sd.png"),
              beginSize: 157,
              endSize: 210,
              milliseconds: 400,
            ),
          ],
        )
    );
  }
}