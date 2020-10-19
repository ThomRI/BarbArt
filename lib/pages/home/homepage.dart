import 'package:barbart/api/APIValues.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/components/SocialPostItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../main.dart';

// ignore: must_be_immutable
class HomePage extends AbstractPageComponent{
  HomePage({Key key}) : super(key: key);

  @override
  String get name => "Home";

  @override
  Icon get icon => Icon(Icons.home, color: Colors.white);

  @override
  Image get logo => Image(image: AssetImage("assets/logo_clipped.png"));

  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<ASocialPost> posts = gAPI.socialPosts.values.toList();
    return SafeArea(
      child: Container(
        child: posts.length > 0 ?
          RefreshIndicator(
            onRefresh: () async {
              gAPI.update(APIFlags.SOCIAL_POSTS, onUpdateDone: () {
                this.setState(() {});
              });
            },
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0, bottom: 260),
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                return SocialPostItem(socialPost: posts[index],);
              },
            ),
          ) : Center(
          child: Text("Waiting for server..."),
        ),
      ),
    );
  }

}