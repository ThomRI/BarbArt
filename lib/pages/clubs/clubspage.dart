import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class ClubsPage extends AbstractPageComponent{
  ClubsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
          child: Text("Clubs Page"),
        )
    );
  }

  @override
  Icon get icon => Icon(Icons.games, color: Colors.white);

  @override
  Icon get logo => Icon(Icons.games, color: Colors.white, size: 100);

  @override
  String get name => "Clubs";

  @override
  _ClubsPageState createState() => new _ClubsPageState();
  
}

class _ClubsPageState extends State<ClubsPage> {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage("assets/comingsoon.png"),
      //width: deviceSize(context).width,
      fit: BoxFit.scaleDown,
    );
  }

}