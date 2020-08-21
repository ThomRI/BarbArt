import 'package:barbart/api/APIValues.dart';
import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/components/SocialPostItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../main.dart';

class HomePage extends StatefulWidget implements AbstractPageComponent{
  HomePage({Key key}) : super(key: key);

  @override
  String get name => "Accueil";

  @override
  Icon get icon => Icon(Icons.home, color: Colors.white);

  @override
  Image get logo => Image(image: AssetImage("assets/logo_clipped.png"));

  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  bool _pending = true; // Waiting for the server

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: gAPI.socialPosts.length > 0 ?
        RefreshIndicator(
          onRefresh: () async {
            gAPI.update(APIFlags.SOCIAL_POSTS, onUpdateDone: () {
              this.setState(() {});
            });
          },
          child: ListView.builder(
            padding: EdgeInsets.only(top: 10.0, bottom: 230),
            itemCount: gAPI.socialPosts.length,
            itemBuilder: (BuildContext context, int index) {
              return SocialPostItem(socialPostLocalId: index,);
            },
          ),
        ) : Center(
        child: Text("Waiting for server..."),
      ),
    );
  }

}