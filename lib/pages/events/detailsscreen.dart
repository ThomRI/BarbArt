import 'package:barbart/pages/events/detailsbody.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../main.dart';

class DetailsScreen extends StatelessWidget {
  final int eventId;

  DetailsScreen({@required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(gAPI.events[eventId].title),
      ),

      body: DetailsBody(
        eventId: this.eventId,
      ),
    );
  }
}