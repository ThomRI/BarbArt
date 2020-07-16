import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget implements AbstractPageComponent {
  EventsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbstractPageComponent.backgroundColor,
      body: Center(
        child: Text("Events Page"),
      ),
    );
  }

  @override
  Icon get icon => Icon(Icons.people, color: Colors.white);

  @override
  Icon get logo => Icon(Icons.people, color: Colors.white, size: 100);

  @override
  String get name => "Évènements";

}