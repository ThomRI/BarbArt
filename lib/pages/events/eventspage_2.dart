import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'gridViewEvent.dart';
import '../data.dart';

class EventsPage2 extends StatelessWidget implements AbstractPageComponent {
  EventsPage2({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData deviceInfo = MediaQuery.of(context);
    final size = deviceInfo.size;
    final orientation = deviceInfo.orientation;
    final dPRatio = deviceInfo.devicePixelRatio;

    //print('${size.aspectRatio} # ${size.width} # ${size.height} # ${orientation.index} # $dPRatio');

    final _eventDates = Map<String, List<int>>();
    String date;

    for (int eventId = 1; eventId < events.length + 1; eventId++) {
      date = events[eventId]['date'];
      if (_eventDates.containsKey(date)) {
        _eventDates[date].add(eventId);
      } else {
        _eventDates.addAll({date: [eventId]});
      }
    }

    return Scaffold(
      backgroundColor: AbstractPageComponent.backgroundColor,
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 70, bottom: 30),
            child: Container(
              child: ListViewDaysEvent(
                eventDates:_eventDates,
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
