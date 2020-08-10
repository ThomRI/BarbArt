import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class ClubsPage extends StatelessWidget implements AbstractPageComponent{
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
  
}