import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

class MusicPage extends StatelessWidget implements AbstractPageComponent {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WeekView(
        dates: [DateTime.now().subtract(Duration(days: 1)), DateTime.now(), DateTime.now().add(Duration(days: 1))],
      ),
    );
  }

  @override
  String get name => "Salle musique";

  @override
  Icon get icon => Icon(Icons.music_note, color: Colors.white);

  @override
  Icon get logo => Icon(Icons.music_note, color: Colors.white, size: 100);


}