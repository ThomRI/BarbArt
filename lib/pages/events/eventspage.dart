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
  List<AEvent> _permanentEventList = new List<AEvent>(); // The API has the responsibility to edit this list

  // The setter makes sure that the list is deleted each time it's replaced
  get permanentEventList => _permanentEventList;
  set permanentEventList(List<AEvent> other) {
    this.permanentEventList.clear();
    this.permanentEventList = other;
  }

  final bool onlyShowFuturePermanentEvents;
  DateTime minimumDateTime, maximumDateTime;

  List<AEvent> _virtualPermanentEvents = new List<AEvent>();

  EventsPage({this.minimumDateTime, this.maximumDateTime, this.onlyShowFuturePermanentEvents = true, Key key}) : super(key: key) {
    minimumDateTime ??= DateTime.now().subtract(Duration(days: 7));
    maximumDateTime ??= DateTime.now().add(Duration(days: 7));

    minimumDateTime = extractDate(minimumDateTime);
    maximumDateTime = extractDate(maximumDateTime);
  }

  @override
  Icon get icon => Icon(Icons.people, color: Colors.white);

  @override
  Icon get logo => Icon(Icons.people, color: Colors.white, size: 100);

  @override
  String get name => "Events";

  @override
  _EventsPageState createState() => _EventsPageState();

  void generateVirtualPermanentEvents() {
    _virtualPermanentEvents.clear();

    for(AEvent event in permanentEventList) {
      DateTime extractedDate = extractDate(event.dateTimeBegin);

      /* Adding every day of the permanent event from the minimum date up to the maximum date */
      int delta_ms = ((onlyShowFuturePermanentEvents) ? extractDate(
          DateTime.now()).millisecondsSinceEpoch : minimumDateTime
          .millisecondsSinceEpoch) - extractedDate.millisecondsSinceEpoch;
      int initial_iteration = delta_ms.sign *
          (delta_ms.abs() / (7 * MS_IN_ONE_DAY))
              .floor(); // Initial number of weeks separating the virtual event corresponding to today's week from the originally created event

      int delta_iteration = -1; // Must start at 0 : is the number of iteration from THE INITIAL ITERATION
      for (DateTime date = extractedDate.add(
          Duration(days: 7 * initial_iteration));
      date.compareTo(maximumDateTime) <= 0;
      date = date.add(Duration(days: 7))) {
        delta_iteration++;

        /* Adding the event to be treated as a classic sub event */
        // No need to add the date in the date list, it will be automatically added when dealing with the sub events
        AEvent virtualEvent = AEvent.clone(event);
        virtualEvent.dateTimeBegin = DateTime(
            date.year, date.month, date.day, event.dateTimeBegin.hour,
            event.dateTimeBegin.minute, event.dateTimeBegin.second);
        virtualEvent.dateTimeEnd = virtualEvent.dateTimeBegin.add(
            event.dateTimeEnd.difference(event
                .dateTimeBegin)); // virtual.end = date + (event.end - event.begin)

        // Dealing with the iteration number of the virtual event
        int iteration = initial_iteration + delta_iteration;
        virtualEvent.global_iteration_number = iteration;
        virtualEvent.iteration_zero_event = event;
        virtualEvent.selfClientIsGoing =
            event.selfClientIsGoingToRelativeIteration[iteration] ??
                false; // Setting the going status of the self client only accordingly of what is stored in the zero-iteration-event

        _virtualPermanentEvents.add(virtualEvent);
      }

      // Sorting virtual events by beginning hour
      _virtualPermanentEvents.sort((a, b) => a.dateTimeBegin.hour.compareTo(b.dateTimeBegin.hour));
    }
  }
}

class _EventsPageState extends State<EventsPage> {
  @override
  Widget build(BuildContext context) {
    return SquareDayView(
      sortingMode: SortingMode.DECREASING,

      minimumDateTime: DateTime.now().subtract(Duration(days: 300)),

      mainEventList: gAPI.events.values.toList(),
      mainText: Text("Events", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),

      subEventList: widget._virtualPermanentEvents,
      subText: Text("Clubs", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))
    );
  }
}