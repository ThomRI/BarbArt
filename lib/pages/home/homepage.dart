import 'package:barbart/api/APIValues.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/components/SocialPostItem.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../main.dart';
import 'editpostpage.dart';

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
                return SocialPostItem (
                  socialPost: posts[index],
                  editMode: false,
                  onEdit: () {
                    Navigator.push(context, MaterialPageRoute(
                    builder: (context) => EditPostPage(socialPost: posts[index],),
                    ));
                  }
                );
              },
            ),
          ) : Center(
          child: Text("Waiting for server..."),
        ),
      ),
    );
  }

  Future<void> showPostDialog(SocialPostItem postItem) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // User must use buttons to quit the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: const Text("Edit post")),
          content: SingleChildScrollView(child: postItem),
          contentPadding: EdgeInsets.only(top: 10.0),

        );
      }
    );
  }
}