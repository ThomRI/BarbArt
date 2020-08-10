import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/main.dart';
import 'package:barbart/pages/events/squaredayview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

class EventsPage extends StatelessWidget implements AbstractPageComponent {
  EventsPage({Key key}) : super(key: key);

  @override
  Icon get icon => Icon(Icons.people, color: Colors.white);

  @override
  Icon get logo => Icon(Icons.people, color: Colors.white, size: 100);

  @override
  String get name => "Évènements";

  @override
  Widget build(BuildContext context) {
    return SquareDayView(

    );
  }


}