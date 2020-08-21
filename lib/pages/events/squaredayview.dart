import 'package:auto_size_text/auto_size_text.dart';
import 'package:barbart/api/APIValues.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/components/routing/FadePageRoute.dart';
import 'package:barbart/components/routing/SlidePageRoute.dart';
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


  SquareDayView({Key key, this.minimumDateTime, this.maximumDateTime, this.sortingMode = SortingMode.INCREASING}) : super(key: key) {
    minimumDateTime ??= extractDate(DateTime.now().subtract(Duration(days: 300)));
    maximumDateTime ??= extractDate(DateTime.now().add(Duration(days: 300)));
  }

  @override
  _SquareDayViewState createState() => _SquareDayViewState();
}

class _SquareDayViewState extends State<SquareDayView> {
  @override
  Widget build(BuildContext context) {
    DateTime today = extractDate(DateTime.now());

    // Storing the relevant dates (between the minimum and maximum ones).
    // TODO : Don't compute this at each builds... A callback for updates from the API ?

    // Map of the events with DateTime from which we only kept the date and not the time.
    Map<DateTime, List<int>> dateEventMap = new Map<DateTime, List<int>>();
    for(DateTime date in gAPI.mappedEventsIndices.keys.toList()) {
      if(date.isBefore(widget.minimumDateTime) || date.isAfter(widget.maximumDateTime))
        continue;

      DateTime extractedDate = extractDate(date);

      if(!dateEventMap.containsKey(extractedDate)) {
        dateEventMap.addAll({extractedDate: new List<int>()});
      }

      dateEventMap[extractedDate] += gAPI.mappedEventsIndices[date];
    }

    List<DateTime> dates = dateEventMap.keys.toList();
    dates.sort((a, b) => (widget.sortingMode == SortingMode.INCREASING) ? a.compareTo(b) : b.compareTo(a)); // Sorting by date

    return Container(
      margin: EdgeInsets.only(top: 65, left: 5, right: 5),
      child: RefreshIndicator(
        onRefresh: () async {
          gAPI.update(APIFlags.EVENTS, onUpdateDone: () {
            this.setState(() {});
          });
        },
        child: ListView.builder( // Vertical event list view
          padding: EdgeInsets.only(top: 5, bottom: 40),
          itemCount: dates.length,
          itemBuilder: (BuildContext context, int dateIndex) {
            return Card(
                //shadowColor: (dates[dateIndex].day < 3) ? Colors.green : Colors.black,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)
                ),

                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
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
                                    fontStyle: FontStyle.italic
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

                      _ListDayView(
                        eventIdList: dateEventMap[dates[dateIndex]],
                      )
                      // Actual grid of event for the date pointed buu the item builder index
                    ],
                  ),
                )
            );
          },
        ),
      ),
    );
  }
}

class _ListDayView extends StatelessWidget {
  final List<int> eventIdList;

  const _ListDayView({Key key, this.eventIdList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,

        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 10,
        ),


        itemCount: eventIdList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(context, FadePageRoute(
                page: DetailsScreen(
                  eventId: eventIdList[index],
                )
              ));
            },

            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 5),

              child: Stack(
                children: <Widget>[
                  Opacity(
                    opacity: 0.8,
                    child: Hero(
                      tag: 'event: ${gAPI.events[eventIdList[index]].id}',
                      child: Container( // Proper event image
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kPrimaryColor,
                            width: 4,
                            style: BorderStyle.solid,
                          ),

                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/event.png"), // EVENT IMAGE URL HERE
                          )
                        )
                      )
                    )
                  ),

                  /* Hovering text */
                  Hero(
                    tag: 'eventText: ${gAPI.events[eventIdList[index]].id}',
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(15),
                      child: SingleChildScrollView( // Permits to avoid text overflowing from the square just before AutoSizeText resized it.
                        scrollDirection: Axis.vertical, // Don't change it to horizontal : otherwise the text keeps begin scrollable
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            AutoSizeText(
                              '${gAPI.events[eventIdList[index]].title}',
                              maxLines: 1,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 30,
                                backgroundColor: Color(0x66FFFFFF),
                              )
                            ),

                            AutoSizeText(
                              gAPI.events[eventIdList[index]].timesToString(),
                              maxLines: 1,
                              style: TextStyle(
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 20,
                                backgroundColor: Color(0x66FFFFFF),
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