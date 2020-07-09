import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget implements AbstractPageComponent {
  EventsPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text("Events page"),
    );
  }

  @override
  Icon get icon => Icon(Icons.people, color: Colors.white);

  @override
  String get name => "Évènements";

}