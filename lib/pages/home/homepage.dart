import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatelessWidget implements AbstractPageComponent{
  HomePage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      key: _scaffoldKey,
      body: Container(
        child: SizedBox(
          height: 500,
          width: 200
        ),
      ),
    );
  }

  @override
  String get name => "Accueil";

  @override
  Icon get icon => Icon(Icons.home, color: Colors.white,);

}