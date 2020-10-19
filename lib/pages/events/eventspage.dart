import 'package:barbart/api/APIValues.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/main.dart';
import 'package:barbart/pages/events/squaredayview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils.dart';

// ignore: must_be_immutable
class EventsPage extends AbstractPageComponent {
  EventsPage({Key key}) : super(key: key);

  @override
  Icon get icon => Icon(Icons.people, color: Colors.white);

  @override
  Icon get logo => Icon(Icons.people, color: Colors.white, size: 100);

  @override
  String get name => "Events";

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {

  /// Generates the events from the clubs FOR NOW THEY ARE ALL PERMANENT
  // TODO : Handle non permanent club events
  List<AEvent> generateClubEvents() {
    List<AEvent> clubEvents = new List<AEvent>();
    gAPI.selfClient.clubsIDs.forEach((int clubID) {
      clubEvents.addAll(gAPI.clubs[clubID].permanentEvents.values.toList());
    });

    return clubEvents;
  }

  @override
  Widget build(BuildContext context) {
    return SquareDayView(
      sortingMode: SortingMode.DECREASING,

      minimumDateTime: DateTime.now().subtract(Duration(days: 300)),

      mainEventList: gAPI.events.values.toList(),
      mainText: Text("Events", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),

      subPermanentEventList: gAPI.clubs[2].permanentEvents.values.toList(),
      subText: Text("Clubs", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
    );
  }
}