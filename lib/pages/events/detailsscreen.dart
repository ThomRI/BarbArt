import 'package:barbart/api/structures.dart';
import 'package:barbart/pages/events/detailsbody.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../main.dart';

class DetailsScreen extends StatelessWidget {
  final AEvent event;

  DetailsScreen({@required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(event.title),
      ),

      body: DetailsBody(
        event: this.event,
      ),
    );
  }
}