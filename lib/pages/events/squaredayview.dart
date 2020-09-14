import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barbart/api/APIValues.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/components/routing/FadePageRoute.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../utils.dart';
import 'detailsscreen.dart';

enum SortingMode {
  INCREASING,
  DECREASING
}

// ignore: must_be_immutable
class SquareDayView extends StatefulWidget {
  DateTime  minimumDateTime, maximumDateTime;

  final SortingMode sortingMode;
  final bool weekDistinction; // Only this week is colored, the rest is in gray

  List<AEvent> mainEventList; // Rendered as a big clickable square
  List<AEvent> subEventList;  // Rendered as a little rectangle below the squares PERMANENT FOR NOW
  List<AEvent> subPermanentEventList;

  final Text mainText;
  final Text subText;

  final bool futureSubOnly;


  SquareDayView({Key key, this.minimumDateTime, this.maximumDateTime, this.sortingMode = SortingMode.DECREASING, this.weekDistinction = true, this.mainEventList, this.subEventList, this.subPermanentEventList, this.mainText, this.subText, this.futureSubOnly = true}) : super(key: key) {
    minimumDateTime ??= DateTime.now().subtract(Duration(days: 7));
    maximumDateTime ??= DateTime.now().add(Duration(days: 7));

    minimumDateTime = extractDate(minimumDateTime);
    maximumDateTime = extractDate(maximumDateTime);

    // Dealing with null parameters
    mainEventList ??= new List<AEvent>();
    subEventList ??= new List<AEvent>();
    subPermanentEventList ??= new List<AEvent>();
  }

  @override
  _SquareDayViewState createState() => _SquareDayViewState();
}

class _SquareDayViewState extends State<SquareDayView> {
  DateTime today;

  Map<DateTime, List<AEvent>> _mainEventMap     = new Map<DateTime, List<AEvent>>(); // Map of the events with DateTime from which we only kept the date and not the time.
  Map<DateTime, List<AEvent>> _subEventMap      = new Map<DateTime, List<AEvent>>(); // Same for the sub events
  List<AEvent> subPermEvents = new List<AEvent>(); // Permanent events. Do not put them in the subEventList otherwise when refreshing it is not possible to differentiate them from the real sub events.

  List<DateTime> dates = new List<DateTime>(); // List of rendered dates

  @override
  void initState() {
    super.initState();

    refresh();
  }

  void refresh() {
    today = extractDate(DateTime.now());

    // Storing the relevant dates (between the minimum and maximum ones).
    // TODO : Don't compute this at each builds... A callback for updates from the API ?

    _mainEventMap.clear();
    _subEventMap.clear();
    subPermEvents.clear();
    dates.clear(); // Stores the relevant dates to render

    // Dealing with main events
    for(AEvent event in widget.mainEventList) {
      if(event.dateTimeBegin.isBefore(widget.minimumDateTime) || event.dateTimeEnd.isAfter(widget.maximumDateTime))
        continue;

      DateTime extractedDate = extractDate(event.dateTimeBegin);
      if(!dates.contains(extractedDate)) dates.add(extractedDate); // Adding the date

      if(!_mainEventMap.containsKey(extractedDate)) _mainEventMap.addAll({extractedDate: new List<AEvent>()});
      _mainEventMap[extractedDate].add(event);
    }


    // Dealing with PERMANENT sub events
    int idCursor = 0;

    for(AEvent event in widget.subPermanentEventList) {
      DateTime extractedDate = extractDate(event.dateTimeBegin);

      /* Adding every day of the permanent event from the minimum date up to the maximum date */
      int delta_ms = ((widget.futureSubOnly) ? extractDate(DateTime.now()).millisecondsSinceEpoch : widget.minimumDateTime.millisecondsSinceEpoch) - extractedDate.millisecondsSinceEpoch;
      for(DateTime date = extractedDate.add(Duration(days: delta_ms.sign * 7 * (delta_ms.abs() / (7 * MS_IN_ONE_DAY)).floor()));
      date.compareTo(widget.maximumDateTime) <= 0;
      date = date.add(Duration(days: 7))) {

        /* Adding the event to be treated as a classic sub event */
        // No need to add the date in the date list, it will be automatically added when dealing with the sub events
        AEvent virtualEvent = AEvent.clone(event);
        virtualEvent.id = idCursor; idCursor++;
        virtualEvent.dateTimeBegin = DateTime(date.year, date.month, date.day, event.dateTimeBegin.hour, event.dateTimeBegin.minute, event.dateTimeBegin.second);
        virtualEvent.dateTimeEnd = virtualEvent.dateTimeBegin.add(event.dateTimeEnd.difference(event.dateTimeBegin)); // virtual.end = date + (event.end - event.begin)

        subPermEvents.add(virtualEvent);
      }
    }


    // Dealing with sub events
    for(AEvent event in List.from(widget.subEventList)..addAll(subPermEvents)) {
      // We check the interval of date only if the event isn't a permanent
      if(event.dateTimeBegin.isBefore(widget.futureSubOnly ? extractDate(DateTime.now()) : widget.minimumDateTime) || event.dateTimeEnd.isAfter(widget.maximumDateTime))
        continue;

      DateTime extractedDate = extractDate(event.dateTimeBegin);
      if(!dates.contains(extractedDate)) dates.add(extractedDate); // Adding the date

      if(!_subEventMap.containsKey(extractedDate)) _subEventMap.addAll({extractedDate: new List<AEvent>()});
      _subEventMap[extractedDate].add(event);
    }


    dates.sort((a, b) => (widget.sortingMode == SortingMode.INCREASING) ? a.compareTo(b) : b.compareTo(a)); // Sorting by date
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 65, left: 10, right: 10),

      child: RefreshIndicator(
        onRefresh: () async {
          gAPI.update(APIFlags.EVENTS | APIFlags.CLUBS, onUpdateDone: () {
            this.setState(() {
              refresh();
            });
          });
        },
        child: ListView.builder( // Vertical event list view
          padding: EdgeInsets.only(top: 5, bottom: 40),
          itemCount: dates.length,
          itemBuilder: (BuildContext context, int dateIndex) {

            return Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 2, color: Colors.grey[200])),
              ),
              padding: EdgeInsets.only(bottom: 10),


              child: Column(
                children: <Widget>[
                  Row( // Calendar icon + day text row
                    children: <Widget>[
                      // Calendar icon
                      Container(
                        child: Icon(Icons.calendar_today, color: (dates[dateIndex] == today) ? Colors.red.withOpacity(0.7) : kPrimaryColor),
                        padding: EdgeInsets.all(5),
                      ),

                      // Day text container
                      Container(
                          width: deviceSize(context).width * 0.3333, // 1/3 of the width
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: 5,
                              right: 5,
                              left: 0,
                              bottom: 5
                          ),
                          child:  Text(
                            DateFormat("EEEE").format(dates[dateIndex]),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: (dates[dateIndex] == today) ? Colors.red.withOpacity(0.7) : kPrimaryColor,
                                fontStyle: FontStyle.italic,
                                fontSize: 13
                            ),

                            textScaleFactor: 2,
                          )
                      ),

                      Expanded(
                        child: Text(
                          DateFormat("dd/MM").format(dates[dateIndex]),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic
                          ),

                          textScaleFactor: 1.5,
                        ),
                      )

                    ],
                  ),

                  Container( // Used to filter the color whilst being able to disable the filter

                    /* Date already passed filter */
                    foregroundDecoration: widget.weekDistinction && dates[dateIndex].compareTo(today) < 0 ? BoxDecoration(
                      color: Colors.grey[200],
                      backgroundBlendMode: BlendMode.saturation,
                    ) : null,

                    child: Column(
                      children: [

                        /* Main event list */
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: _mainEventMap.containsKey(dates[dateIndex]) ? widget.mainText : Container(),
                              ),
                            ),

                            Expanded(
                              child: _ListDayView(
                                eventList: _mainEventMap[dates[dateIndex]],
                                renderMode: _ListDayViewRenderMode.RENDER_MAIN,
                              ),
                            ),
                          ],
                        ),

                        /* Sub event list */
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: _subEventMap.containsKey(dates[dateIndex]) ? widget.subText : Container(),
                              ),
                            ),

                            Expanded(
                              child: _ListDayView(
                                eventList: _subEventMap[dates[dateIndex]],
                                renderMode: _ListDayViewRenderMode.RENDER_SUB,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                  // Actual grid of event for the date pointed buu the item builder index
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Different rendering modes for the ListDayView
enum _ListDayViewRenderMode {
  RENDER_MAIN,
  RENDER_SUB,
}

/// Represents a list of main and sub events for a given, fixed, day.
class _ListDayView extends StatelessWidget {
  final List<AEvent> eventList;
  final _ListDayViewRenderMode renderMode;

  const _ListDayView({Key key, this.eventList, this.renderMode = _ListDayViewRenderMode.RENDER_MAIN}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Computing square size depending on the context so that there is always two squares on one screen, and the third visible so that the user understands that he has to scroll to see the rest.
    double _squareSize = deviceSize(context).width * 0.40;

    if(eventList == null) return Container(); // An empty container if there is nothing to render

    return Container(
      height: (renderMode == _ListDayViewRenderMode.RENDER_MAIN) ? _squareSize : 50, // 1/3 for the sub events
      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        separatorBuilder: (BuildContext context, int index) => SizedBox(width: 10),

        itemCount: eventList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            // For now, details are only for the main events
            onTap: (renderMode == _ListDayViewRenderMode.RENDER_MAIN) ? () {
              Navigator.push(context, FadePageRoute(
                page: DetailsScreen(
                  event: eventList[index],
                )
              ));
            } : null,

            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 5),
              width: _squareSize,

              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: Hero(
                      tag: renderMode == _ListDayViewRenderMode.RENDER_MAIN ? 'event: ${eventList[index].id}' : 'eventUnused: ${eventList[index].id}', // Avoid duplicate tags !
                      child: Container( // Proper event background
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kPrimaryColor,
                            width: renderMode == _ListDayViewRenderMode.RENDER_MAIN ? 4 : 2,
                            style: BorderStyle.solid,
                          ),

                          borderRadius: BorderRadius.all(Radius.circular(10.0)),

                          color: (renderMode == _ListDayViewRenderMode.RENDER_SUB) ? Colors.deepOrangeAccent : null,
                          image: (renderMode == _ListDayViewRenderMode.RENDER_MAIN) ? DecorationImage(
                            fit: BoxFit.cover,
                            image: eventList[index].image,
                          ) : null,
                        ),
                      )
                    )
                  ),

                  /* Hovering text */
                  Hero(
                    tag: renderMode == _ListDayViewRenderMode.RENDER_MAIN ? 'eventText: ${eventList[index].id}' : 'eventTextUnused: ${eventList[index].id}', // Avoid duplicates tags !
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView( // Permits to avoid text overflowing from the square just before AutoSizeText resized it.
                        scrollDirection: Axis.vertical, // Don't change it to horizontal : otherwise the text keeps begin scrollable
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            AutoSizeText(
                              '${eventList[index].title}',
                              maxLines: 1,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: renderMode == _ListDayViewRenderMode.RENDER_MAIN ? 30 : 8,
                                backgroundColor: renderMode == _ListDayViewRenderMode.RENDER_MAIN ? Colors.white.withOpacity(0.5) : null,
                              )
                            ),

                            AutoSizeText(
                              eventList[index].timesToString(),
                              maxLines: 1,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: renderMode == _ListDayViewRenderMode.RENDER_MAIN ? 20 : 5,
                                backgroundColor: renderMode == _ListDayViewRenderMode.RENDER_MAIN ? Color(0x66FFFFFF) : null,
                              )
                            )
                          ],
                        ),
                      )

                    ),
                  )
                ],
              )
            )
          );
        },
      ),
    );
  }
  
}