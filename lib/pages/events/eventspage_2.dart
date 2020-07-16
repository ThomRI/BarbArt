import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'gridViewDays.dart';
import 'data.dart';

class EventsPage2 extends StatelessWidget implements AbstractPageComponent {
  EventsPage2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const double factor = 0.09;

    final _eventName = <String>[];
    final _eventDate = <String>[];
    final _eventTime = <String>[];
    final _eventImage = <String>[];
    final _eventDescription = <String>[];

    for (int event_id = 1; event_id < events.length + 1; event_id++) {
      Map<String, String> dict_event = events[event_id];
      _eventName.add(dict_event['name']);
      _eventDate.add(dict_event['date']);
      _eventTime.add(dict_event['time']);
      _eventImage.add(dict_event['image']);
      _eventDescription.add(dict_event['description']);
    }

    return Scaffold(
      backgroundColor: AbstractPageComponent.backgroundColor,
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 70, bottom: 30),
            child: Container(
              child: GridViewDays(
                eventName: _eventName,
                eventDate: _eventDate,
                eventTime: _eventTime,
                eventImage: _eventImage,
                eventDescription: _eventDescription,
              ),
            ),
          ),
        ],
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
