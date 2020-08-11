import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/components/ControlledCarousel.dart';
import 'package:barbart/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatelessWidget implements AbstractPageComponent{
  HomePage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbstractPageComponent.backgroundColor,

      key: _scaffoldKey,
      body: Container(
        margin: EdgeInsets.only(bottom: 300),
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: const Text("Home Page"),
                ),
              ),
            ],
          )

          ),
        ),
      );
  }

  @override
  String get name => "Accueil";

  @override
  Icon get icon => Icon(Icons.home, color: Colors.white);

  @override
  Image get logo => Image(image: AssetImage("assets/logo_clipped.png"));

}