import 'package:barbart/constants.dart';

import '../myClipper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../data.dart';

class DetailsScreen extends MaterialPageRoute<Null> {
  final String titleString;
  final String dayString;
  final String timeString;
  final String imagePath;
  final String description;

  DetailsScreen(this.titleString, this.dayString, this.timeString,
      this.imagePath, this.description)
      : super(builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: background_color,
            appBar: AppBar(
              title: Text(titleString),
            ),
            body: Center(
              child: ListView(children: <Widget>[
                ClipPath(
                  clipper: MyClipper(),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(bottom: 30, right: 30, left: 30),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: ' $titleString \n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 30,
                        backgroundColor: const Color(0x66FFFFFF),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text:
                              ' ${dayString.substring(0, 1).toUpperCase() + dayString.substring(1)} : $timeString ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: ' \n\n$description ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            //color: Colors.white,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 100,
                  height: 70,
                  decoration: BoxDecoration(
                    // shape: BoxShape.circle,
                    // border: new Border.all(
                    //   color: primary_color,
                    //   width: 5,
                    //   style: BorderStyle.solid,
                    // ),
                    image: const DecorationImage(
                      fit: BoxFit.scaleDown,
                      image: AssetImage('assets/images/logo-barbart2.png'),
                    ),
                  ),
                ),
              ]),
            ),
          );
        });
}
