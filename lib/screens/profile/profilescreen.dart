import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:barbart/components/ColoredButton.dart';
import 'package:barbart/components/StylizedTextField.dart';
import 'package:barbart/components/routing/SlidePageRoute.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/screens/profile/clubsselectionscreen.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../main.dart';
import '../../utils.dart';
import '../mainscreen.dart';

class _ProfilePageConstants {
  static final String OldPasswordValidationText = "Ok";
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  CarouselController _passwordCarouselController;
  int _passwordCarouselCurrentPage = 0;

  /* Old password */
  TextEditingController _oldPasswordFieldController;
  RoundedLoadingButtonController _oldPasswordButtonController;

  /* New password */
  TextEditingController _newPasswordFieldController;
  RoundedLoadingButtonController _newPasswordButtonController;

  /* Avatar change pending */
  bool _avatarChangePending = false;

  void carouselNextPage() {
    _passwordCarouselController.nextPage();
    _passwordCarouselCurrentPage++;
  }

  void carouselPreviousPage() {
    _passwordCarouselController.previousPage();
    _passwordCarouselCurrentPage--;
  }

  @override
  void initState() {
    super.initState();

    // Initiating the change password fields controller
    _passwordCarouselController = new CarouselController();

    // Old password controllers
    _oldPasswordFieldController = new TextEditingController();
    _oldPasswordButtonController = new RoundedLoadingButtonController();

    // New password controllers
    _newPasswordFieldController = new TextEditingController();
    _newPasswordButtonController = new RoundedLoadingButtonController();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () {
          if(_passwordCarouselCurrentPage == 0) {
            Navigator.of(context).pop();
          }

          /* Clearing previous fields */
          if(_passwordCarouselCurrentPage == 2) _oldPasswordFieldController.clear();

          carouselPreviousPage();
          return;
        },

        child: Scaffold(
          appBar: AppBar(title: const Text("Profile")),
          backgroundColor: kBackgroundColor,
          body: Stack(
            children: <Widget>[

              /* Corner images */
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[

                  /* Pic image */
                  Transform.rotate(
                    angle: pi/5,
                    child: Image(width: deviceSize(context).width / 4, height: deviceSize(context).width / 4, image: AssetImage("assets/barbart/pickaxe.png")),
                  ),

                  /* Pickaxe image */
                  Transform.rotate(
                    angle: -pi/5,
                    child: Image(width: deviceSize(context).width / 4, height: deviceSize(context).width / 4, image: AssetImage("assets/barbart/pic.png")),
                  )

                ],
              ),

              /* Main Column */
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[

                  /* Avatar */
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: <Widget>[
                        Stack(
                          children: [
                            Align(
                              child: _avatarChangePending ? SizedBox(
                                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor), strokeWidth: 7, ),
                                width: 160,
                                height: 160
                              ) : null,
                              alignment: Alignment.center,
                            ),

                            Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                radius: 80,
                                backgroundImage: gAPI.selfClient.avatar,
                                backgroundColor: kDefaultCircleAvatarBackgroundColor,
                                child: Align(
                                  alignment: Alignment.bottomRight,

                                  /* Edit avatar button */
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _avatarChangePending ? Colors.grey : kPrimaryColor,
                                    ),

                                    child: IconButton(
                                      icon:  const Icon(Icons.edit, color: Colors.white),
                                      onPressed: () async {

                                        /* ####################################### */
                                        /* ###### HERE AVATAR UPDATE ACTION ###### */
                                        /* ####################################### */

                                        if(_avatarChangePending) return; // Forbid to change the avatar if one is already being uploaded.

                                        PickedFile file = await ImagePicker().getImage(source: ImageSource.gallery);
                                        if(file == null) return;

                                        gAPI.registerAvatar(
                                          avatarFile: File(file.path),

                                          onConfirmed: () {
                                            this.setState(() {
                                              this._avatarChangePending = false;
                                            });
                                          }
                                        );

                                        // Changing UI to indicate that the avatar is changing
                                        this.setState(() {
                                          this._avatarChangePending = true;
                                        });
                                      },
                                    )
                                  )
                                )
                              ),
                            ),
                          ],
                        ),

                        /* Firstname & Lastname Text */
                        Text(
                          gAPI.selfClient.firstname + " " + gAPI.selfClient.lastname,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          )
                        ),

                        /* Email address Text */
                        Text(
                          gAPI.selfClient.email,
                          style: TextStyle(
                            fontSize: 10,
                          )
                        ),

                        // Space between avatar and buttons
                        SizedBox(
                          height: 100,
                        ),


                        /* Change password carousel */
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 50.0),

                          child: CarouselSlider(
                            carouselController: _passwordCarouselController,

                            options: CarouselOptions(
                              enableInfiniteScroll: false,
                              scrollPhysics: NeverScrollableScrollPhysics(),
                              viewportFraction: 1,
                            ),

                            items: <Widget>[

                              /* Change Password & Clubs you follow buttons */
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  /* Change password button */
                                  ColoredButton(
                                      text: "Change password",
                                      iconData: Icons.lock,
                                      enableColor: false,

                                      onTap: () {

                                        /* ######################################### */
                                        /* ###### HERE CHANGE PASSWORD ACTION ###### */
                                        /* ######################################### */

                                        carouselNextPage();
                                      }
                                  ),

                                  /* Clubs you follow button */
                                  ColoredButton(
                                    text: "Clubs you follow",
                                    iconData: Icons.grid_on,
                                    enableColor: false,

                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ClubsSelectionScreen()));
                                    },
                                  )
                                ],
                              ),

                              /* Old password field */
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  /* Old password field */
                                  StylizedTextField(
                                    fieldController: _oldPasswordFieldController,
                                    hint: "Old password",
                                    obscure: true,
                                    width: deviceSize(context).width * kDefaultButtonWidthRatio,
                                    height: 55,
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),

                                  /* Old password validation button */
                                  RoundedLoadingButton(
                                    width: deviceSize(context).width * kDefaultButtonWidthRatio,
                                    controller: _oldPasswordButtonController,
                                    child: Text(_ProfilePageConstants.OldPasswordValidationText, style: TextStyle(color: Colors.white)),
                                    onPressed: () {
                                      _oldPasswordButtonController.start();

                                      /* ############################################ */
                                      /* ###### HERE OLD PASSWORD CHECK ACTION ###### */
                                      /* ############################################ */


                                      gAPI.checkCredentials(password: _oldPasswordFieldController.text, onConfirmed: (bool success) {
                                        if(success) _oldPasswordButtonController.success();
                                        else        _oldPasswordButtonController.error();

                                        // Reset
                                        Timer(Duration(seconds: 1), () {
                                          _oldPasswordButtonController.reset();
                                          if(success) {
                                            _oldPasswordFieldController.clear();
                                            carouselNextPage();
                                          }
                                        });
                                      });

                                    },
                                  )
                                ],
                              ),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  /* New password field */
                                  StylizedTextField(
                                    fieldController: _newPasswordFieldController,
                                    obscure: true,
                                    hint: "New password",
                                    width: deviceSize(context).width * kDefaultButtonWidthRatio,
                                    height: 55,
                                  ),

                                  SizedBox(
                                    height: 20,
                                  ),

                                  /* New password validation button */
                                  RoundedLoadingButton(
                                    controller: _newPasswordButtonController,
                                    width: deviceSize(context).width * kDefaultButtonWidthRatio,

                                    child: const Text("Confirm", style: TextStyle(color: Colors.white)),

                                    onPressed: () {
                                      _newPasswordButtonController.start();

                                      /* ######################################### */
                                      /* ###### HERE PASSWORD UPDATE ACTION ###### */
                                      /* ######################################### */

                                      gAPI.updateCredentials(password: _newPasswordFieldController.text, onConfirmed: (bool success) {
                                        if(success) _newPasswordButtonController.success();
                                        else        _newPasswordButtonController.error();

                                        // Reset
                                        Timer(Duration(seconds: 1), () {
                                          // Jumping back to first carousel page
                                          if(success) {
                                            _newPasswordButtonController.reset();

                                            _passwordCarouselController.animateToPage(0);
                                            _passwordCarouselCurrentPage = 0;

                                            // Clearing fields
                                            _newPasswordFieldController.clear();
                                          }
                                        });
                                      });
                                    },
                                  )
                                ],
                              ),

                            ]
                          ),
                        ),

                        /* Space between change password/clubs you follow buttons & Log Out buttons */
                        SizedBox(height: 50,),

                        ColoredButton(
                          text: "Log out",
                          iconData: Icons.cancel,

                          onTap: () {

                            /* ################################# */
                            /* ###### HERE LOG OUT ACTION ###### */
                            /* ################################# */

                            gAPI.logout();
                            MainScreen.pushToLogin(context);
                          },
                        )

                      ],
                    ),
                  ),


                ],
              )
            ],
          )
        ),
      )
    );
  }
}