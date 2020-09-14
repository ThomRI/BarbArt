import 'dart:io';

import 'package:barbart/api/APIManager.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import '../main.dart';
import '../utils.dart';
import 'TextIcon.dart';

class _PopupMenuItems {
  static const String Delete    = "Delete";
  static const String Tags      = "Tags";
  static const String MainText  = "MainText";
}

class _SocialPostItemUIState {
  bool  liked = false,
        commented = false;
}

class SocialPostItem extends StatefulWidget {
  final ASocialPost socialPost;

  const SocialPostItem({Key key, this.socialPost}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SocialPostItemState();
}

class SocialPostItemState extends State<SocialPostItem> {
  _SocialPostItemUIState UIState = new _SocialPostItemUIState();

  @override
  void initState() {
    super.initState();

    /* Fetching if the client has liked this post */
    widget.socialPost.hasLiked(
      gAPI.selfClient,
      onConfirmed: (bool liked) {
        this.setState(() {
          this.UIState.liked = liked;
        });
      }
    );

    /* Updating when the number of likes has been updated */
    widget.socialPost.nbrLikesNotifier.addListener(() {
      if(this.mounted) this.setState(() {}); // Redrawing this post
    });
  }

  @override
  Widget build(BuildContext context) {
    AClient author = gAPI.clientFromUUID(widget.socialPost.clientUUID);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          /* Post Header */
          Row(
            children: <Widget>[
              
              CircleAvatar(
                radius: 25,
                backgroundImage: author.avatar,
                backgroundColor: kDefaultCircleAvatarBackgroundColor,
              ),
              SizedBox(width: 10,),

              /* Header infos */
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(author.firstname + " " + author.lastname, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(ago(widget.socialPost.datetime) + " ago.", style: TextStyle(fontSize: 15, color: Colors.grey)),
                ],
              )
            ],
          ),

          /* Post tags */
          Container(
            margin: EdgeInsets.only(top: 10, bottom: 20),
            child: Tags(
              itemCount: widget.socialPost.tags.length,
              itemBuilder: (int tagIndex) {
                return ItemTags(
                  key: Key('itemtag' + tagIndex.toString()),
                  index: tagIndex,
                  title: widget.socialPost.tags[tagIndex],
                  color: kPrimaryColor,
                  elevation: 3,
                  textColor: Colors.white,
                  active: false,
                  pressEnabled: false,
                  textStyle: TextStyle(fontSize: 14),
                );
              }
            ),
          ),

          /* Post body (main text) */
          Container(
            width: deviceSize(context).width,
            padding: EdgeInsets.all(10.0),
            child: Text(
              widget.socialPost.body,
              textAlign: TextAlign.justify,
            ),
          ),

          /* Interactions bar bellow the post body (Likes, Comments, ...) */
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

                // Like button
                TextIcon(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey[400], width: 0.1),
                  ),

                  icon: Icon(
                    Icons.thumb_up,
                    color: UIState.liked ? Colors.green : Colors.grey[400]
                  ),

                  text: Text(widget.socialPost.nbrLikesNotifier.value.toString() + ' likes'),

                  // Like button pressed
                  onPressed: () {
                    // Notifying the server. If the request failed, we change back the UI.
                    widget.socialPost.setLike(
                      gAPI.selfClient,
                      liked: !UIState.liked, // We request the opposite
                      onConfirmed: (bool success) {
                        this.setState(() { // Always set state regardless of the success state because we have to update the the number of likes if succeeded, and update the UIState if the request was unsuccessful.
                          if(!success) this.UIState.liked = !this.UIState.liked; // If it failed, change back the UI that has been changed the moment the user clicked on the button.
                        });
                      }
                    );

                    // Update the UI regardeless of the server's reaction in case of bad connection. We want the UI to be responsive.
                    // Note: It only updates the like button and not the text !
                    // Note : Do this after the request so that the UI state remains the former when calling setLike
                    this.setState(() {
                      this.UIState.liked = !this.UIState.liked;
                    });

                  },
                ),

                // Comments button
                /*TextIcon(
                  icon: Icon(
                    Icons.chat_bubble,
                    color: Colors.grey[400],
                  ),

                  text: Text(socialPost.nbrComments.toString() + ' comments'),

                  onPressed: () {
                    // TODO: implement the comments system
                  }
                )*/

              ],
            ),
          ),

          Divider(),

        ],
      )
    );
  }

}