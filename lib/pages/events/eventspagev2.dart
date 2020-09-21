import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barbart/data.dart';
import 'package:barbart/gridViewDays.dart';

class EventsPagev2 extends StatelessWidget implements AbstractPageComponent {
  EventsPagev2({Key key}) : super(key: key);

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
      body: Stack(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(right: 10, left: 10),
            child: Container(
              //alignment: Alignment.center,
              color: Colors.white,
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
    // This trailing comma makes auto-formatting nicer for build methods.
  }

  @override
  Icon get icon => Icon(Icons.people, color: Colors.white);

  @override
  String get name => "Évènements";

  @override
  get bigHeader => false;

  @override
  // TODO: implement logo
  get logo => throw UnimplementedError();


}