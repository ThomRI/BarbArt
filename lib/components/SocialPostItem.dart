import 'dart:async';
import 'dart:math';

import 'package:barbart/api/APIValues.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/constants.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tags/flutter_tags.dart';

import '../main.dart';
import '../utils.dart';
import 'TextIcon.dart';
import 'messageloadingbutton.dart';

class _PopupMenuItems {
  static const String Delete    = "Delete";
  static const String Tags      = "Tags";
  static const String MainText  = "MainText";
}

class _SocialPostItemUIState {
  bool  liked = false,
      commented = false;

  bool pending = false;

  // Admin
  ValueNotifier<bool> _editingMainText = new ValueNotifier<bool>(false);
  bool get editingMainText => _editingMainText.value;
  set editingMainText(bool other) {_editingMainText.value = other;}

  ValueNotifier _editingTags = new ValueNotifier<bool>(false);
  bool get editingTags => _editingTags.value;
  set editingTags(bool other) {_editingTags.value = other;}

  void addEditStateChangedListener(Function(bool isEditing) callback) {
    this._editingMainText.addListener(() {callback(_editingMainText.value || _editingTags.value);});
    this._editingTags.addListener(() {callback(_editingTags.value || _editingTags.value);});
  }
}

class SocialPostItem extends StatefulWidget {
  final ASocialPost socialPost;
  final Function onEdit; // Called when the edit button is pressed, not when the actual text is edited TODO: Change that ?
  final bool editMode; // Editing by clicking the body text

  const SocialPostItem({Key key, this.socialPost, this.onEdit, this.editMode = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SocialPostItemState();
}

class SocialPostItemState extends State<SocialPostItem> {
  _SocialPostItemUIState UIState = new _SocialPostItemUIState();

  TextEditingController _tagController;
  TextEditingController _mainTextController;
  ExpandableController _expandableController;

  Container bodyTextContainer;

  @override
  void initState() {
    super.initState();

    /* Fetching if the client has liked this post */
    widget.socialPost.hasLiked(
        gAPI.selfClient,
        onConfirmed: (bool liked) {
          if(this.mounted) {
            this.setState(() {
              this.UIState.liked = liked;
            });
          }
        }
    );

    /* Updating when the number of likes has been updated */
    widget.socialPost.nbrLikesNotifier.addListener(() {
      if(this.mounted) this.setState(() {}); // Redrawing this post
    });

    _tagController = TextEditingController(text: '');
    _mainTextController = TextEditingController(text: widget.socialPost.body);
    _expandableController = ExpandableController(initialExpanded: false,);
  }

  @override
  Widget build(BuildContext context) {

    AClient author = gAPI.clientFromUUID(widget.socialPost.clientUUID);

    /* Initiating body text container */
    GlobalKey<_EditPostItemState> editBodyItemKey = new GlobalKey<_EditPostItemState>();
    GlobalKey<_ClickToEditTextState> clickToEditKey = new GlobalKey<_ClickToEditTextState>();
    bodyTextContainer = Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          widget.editMode ? ClickToEditText(privilegeLevel: APIPrivilege.EDIT_POST, clickToEditKey: clickToEditKey, editingMainText: UIState.editingMainText,) : Container(),
          TextField(
              controller: _mainTextController,
              readOnly: !widget.editMode || !gAPI.selfClient.hasPrivilege(APIPrivilege.EDIT_POST),
              enabled: widget.editMode && gAPI.selfClient.hasPrivilege(APIPrivilege.EDIT_POST), // Enabled only in live edit mode and if the user has necessary privileges. Must be specified on top of readOnly in order for the ExpandableButton to work correctly.
              minLines: 5,
              maxLines: widget.editMode ? 10 : 1000,
              scrollPhysics: BouncingScrollPhysics(),
              style: TextStyle(fontSize: 13.5),

              onTap: () {
                if(!widget.editMode) return;

                clickToEditKey.currentState.setState(() {clickToEditKey.currentState._editingMainText = true;});
                editBodyItemKey.currentState.setState(() {editBodyItemKey.currentState._editingMainText = true;});
              },

              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(0),
              )
          ),

          EditPostItem(
            editBodyItemKey: editBodyItemKey,
            editingMainText: UIState.editingMainText,
            onCancel: (){
              setState(() {
                _mainTextController.clear();
                _mainTextController.text = widget.socialPost.body;
                UIState.editingMainText = false;
              });},

            onSubmit: () {
              setState(() {
                // TODO: change text in server
                _mainTextController.clear();
                _mainTextController.text = widget.socialPost.body;
                UIState.editingMainText = false;
              });
            },
          ),
        ],
      ),// TEXT
    );

    return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: <Widget>[
            /* Post Header */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
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
                    ),
                  ],
                ),

                /* Popup Menu */
                /*! _admin ? Container() : PopupMenuButton(
                icon: Icon(Icons.more_horiz), //TODO: Implements onPressed or delete the widget
                itemBuilder: (BuildContext context){
                  return adminActions.map((String actionStr) {
                    return PopupMenuItem<String>(
                        value: actionStr,
                        child: Text(actionStr)
                    );
                  }).toList();
                },
                onSelected: (str) async{
                  if (str == "Delete"){
                    print("delete item ${widget.socialPost.title}"); // TODO: Implements function to delete this post
                  }
                  else if (str == "Tags") {
                    print("tags item number ${widget.socialPost.title}"); // TODO: Implements function to change post in server
                    setState(() {
                      _editingTags = true;
                    });
                  }
                  else if (str == "MainText"){ // TODO: Implements function to change post in server
                    print("text item number ${widget.socialPost.title}");
                    setState(() {
                      _editingMainText = true;
                    });
                  }
                },
              )*/


                /* Edit & Delete buttons */
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    children: [
                      /* Edit post button */
                      gAPI.selfClient.hasPrivilege(APIPrivilege.EDIT_POST) && !widget.editMode ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: widget.onEdit,
                      ) : Container(),

                      /* Delete post button */
                      !gAPI.selfClient.hasPrivilege(APIPrivilege.EDIT_POST) ? Container() : IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: (){

                          /* ################################# */
                          /* #### HERE POST DELETE ACTION #### */
                          /* ################################# */

                          setState(() {
                            print("delete item ${widget.socialPost.title}"); // TODO: Implements function to delete this post

                            _DeleteConfirmationComponent.show(context, title: Text("Do you want to delete this post ?", textAlign: TextAlign.center,));
                          });

                        },
                        padding: EdgeInsets.all(5),
                      ),
                    ],
                  ),
                )
              ],
            ),

            /* Post tags */
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 20),
              child: Tags(

                  itemCount: widget.socialPost.tags.length,
                  textField: UIState.editingTags ? TagsTextField(
                    textStyle: TextStyle(fontSize: 14),
                    onSubmitted: (String str) {
                      // Add item to the data source.
                      setState(() {
                        // TODO : add str to server
                        print(str);
                      });
                    },
                  ): null,
                  itemBuilder: (int tagIndex) {
                    return ItemTags(
                      key: Key('itemtag' + tagIndex.toString()),
                      index: tagIndex,
                      title: widget.socialPost.tags[tagIndex],
                      color: kPrimaryColor,
                      elevation: 3,
                      textColor: Colors.white,
                      active: false,
                      pressEnabled: true,
                      textStyle: TextStyle(fontSize: 14),
                      textActiveColor: Colors.white,
                      activeColor: kPrimaryColor,
                      highlightColor: kPrimaryColor,
                      removeButton: UIState.editingTags ? ItemTagsRemoveButton(
                        onRemoved: (){
                          // Remove the item from the data source.
                          setState(() {
                            //TODO : remove from server
                            print("remove "+ widget.socialPost.tags[tagIndex]);
                          });
                          //required
                          return true;
                        },
                      ) : null,
                      onPressed: (item) {

                        /* Here onPressed for editing tags */

                        if(!widget.editMode) return;

                        if(!gAPI.selfClient.hasPrivilege(APIPrivilege.EDIT_POST)) return;
                        setState(() {
                          UIState.editingTags = !UIState.editingTags;
                        });
                      },
                    );
                  }
              ),
            ),

            /* Post body (main text) */
            !widget.editMode ? ExpandableNotifier(
              controller: _expandableController,

              child: Expandable(
                collapsed: ExpandableButton(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          width: deviceSize(context).width,
                          padding: EdgeInsets.all(10.0),
                          child: Text(widget.socialPost.body, style: TextStyle(fontSize: 13.5), maxLines: 5, overflow: TextOverflow.ellipsis)
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: const Text("Click to see more", style: const TextStyle(color: Colors.grey)),
                      ),
                    ],
                  )
                ),

                expanded: ExpandableButton(
                  child: bodyTextContainer,
                ),
              ),
            ) : bodyTextContainer,

            /* Post Image */
            widget.socialPost.image != null ? Image(
              image: widget.socialPost.image,
            ) : Container(),

            /* Interactions bar bellow the post body (Likes, Comments, ...) */
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[

                  /* Like button */
                  !widget.editMode ? TextIcon( // Do not show the like button in edit mode !
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    width: 120 + 10*(log(widget.socialPost.nbrLikesNotifier.value) / ln10).floorToDouble(),
                    animate: true,

                    checked: this.UIState.liked,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey[400], width: 0.5),
                    ),

                    icon: Icon(Icons.thumb_up,),

                    text: Text(widget.socialPost.nbrLikesNotifier.value.toString() + ' likes'),

                    // Like button pressed
                    onPressed: () {

                      /* ################################### */
                      /* ######## HERE LIKE ACTION ######### */
                      /* ################################### */

                      // Notifying the server. If the request failed, we change back the UI.
                      widget.socialPost.setLike(
                        gAPI.selfClient,
                        liked: !UIState.liked, // We request the opposite
                        onConfirmed: (bool success) {
                          if(this.mounted)  this.setState(() { // Always set state regardless of the success state because we have to update the the number of likes if succeeded, and update the UIState if the request was unsuccessful.
                            if(!success) this.UIState.liked = !this.UIState.liked; // If it failed, change back the UI that has been changed the moment the user clicked on the button.
                          });
                        },

                        changeValueOnTrigger: true,
                      );

                      // Update the UI regardeless of the server's reaction in case of bad connection. We want the UI to be responsive.
                      // Note: It only updates the like button and not the text !
                      // Note : Do this after the request so that the UI state remains the former when calling setLike
                      this.setState(() {
                        this.UIState.liked = !this.UIState.liked;
                      });

                    },
                  ) : Container(),

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

class EditPostItem extends StatefulWidget{

  final bool editingMainText;
  final int privilegeLevel;

  final void Function() onSubmit;// TODO:  will be a Future<bool>
  final void Function() onCancel; // TODO:  will be a Future<bool>


  final GlobalKey<_EditPostItemState> editBodyItemKey;

  const EditPostItem({this.editBodyItemKey, this.editingMainText = false, this.onSubmit, this.onCancel, this.privilegeLevel}) : super(key: editBodyItemKey);

  @override
  _EditPostItemState createState() => _EditPostItemState();
}

class _EditPostItemState extends State<EditPostItem> {

  bool _editingMainText;

  @override
  void initState() {
    _editingMainText = widget.editingMainText;
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return (_editingMainText ? Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.cancel, color: Colors.red),
          onPressed: (){
            widget.onCancel();
          },
          padding: EdgeInsets.all(5),
        ),
        IconButton(
          icon: Icon(Icons.check_circle, color: Colors.green),
          onPressed: (){
            widget.onSubmit();
          },
          padding: EdgeInsets.all(5),
        )
      ],
    ): Container());
  }
}

class ClickToEditText extends StatefulWidget{

  final bool editingMainText;
  final GlobalKey<_ClickToEditTextState> clickToEditKey;
  final int privilegeLevel;

  const ClickToEditText({this.clickToEditKey, this.editingMainText, this.privilegeLevel}) : super(key: clickToEditKey);


  @override
  _ClickToEditTextState createState() => _ClickToEditTextState();
}

class _ClickToEditTextState extends State<ClickToEditText> {

  bool _editingMainText;

  @override
  void initState() {
    _editingMainText = widget.editingMainText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !gAPI.selfClient.hasPrivilege(widget.privilegeLevel) ? Container() : Padding(
      padding: EdgeInsets.only(bottom: 5),
      child: Text(_editingMainText ? ' ' : 'Click to edit', style: TextStyle(color: Colors.grey), textAlign: TextAlign.left,),
    );
  }
}


class _DeleteConfirmationComponent{
  static Future<void> show(BuildContext context, {Text title, Widget headerContent}) async {

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: title,
            content: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  headerContent ?? Container(),
                  Center(
                    child: MessageLoadingButton(
                        width: 200,
                        onPressed: () async {
                          Timer(Duration(seconds: 1), () {
                            Navigator.of(context).pop(); // Close the AlertDialog
                          });
                          return true;
                        }
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

}