import 'dart:io';
import 'dart:math';

import 'package:barbart/api/APIManager.dart';
import 'package:barbart/api/APIValues.dart';
import 'package:barbart/components/ColoredButton.dart';
import 'package:barbart/components/ControlledCarousel.dart';
import 'package:barbart/constants.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../main.dart';
import '../../utils.dart';
import '../mainscreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: gAPI.selfClient.avatar,
                        backgroundColor: kDefaultCircleAvatarBackgroundColor,
                        child: Align(
                          alignment: Alignment.bottomRight,

                          /* Edit avatar button */
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryColor,
                            ),

                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () async {

                                /* ####################################### */
                                /* ###### HERE AVATAR UPDATE ACTION ###### */
                                /* ####################################### */

                                String path = (await ImagePicker().getImage(source: ImageSource.gallery)).path;
                                if(path == null) return;

                                gAPI.registerAvatar(
                                  avatarFile: File(path),

                                  onConfirmed: () {this.setState(() { });}
                                );
                              },
                            )
                          )
                        )
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

                      /* Change Password & Clubs you follow buttons */
                      Container(
                        child: Column(
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


                                }
                            ),

                            /* Clubs you follow button */
                            ColoredButton(
                              text: "Clubs you follow",
                              iconData: Icons.grid_on,
                              enableColor: false,
                              enabled: false,
                            )
                          ],
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
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                      )

                    ],
                  ),
                ),


              ],
            )
          ],
        )
      )
    );
  }
}