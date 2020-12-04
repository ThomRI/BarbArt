import 'package:barbart/api/structures.dart';
import 'package:barbart/components/SocialPostItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditPostPage extends StatelessWidget {
  final ASocialPost socialPost;

  const EditPostPage({Key key, this.socialPost}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit post"),
      ),

      body: Container(
        margin: EdgeInsets.only(top: 10.0),
        child: SocialPostItem(
          socialPost: socialPost,
          editMode: true,
        ),
      ),
    );
  }

}