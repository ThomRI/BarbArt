import 'package:barbart/api/structures.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../utils.dart';

enum SortingMode {
  INCREASING,
  DECREASING
}

// ignore: must_be_immutable
class SquareDayView extends StatelessWidget {
  DateTime  minimumDateTime, maximumDateTime;

  final SortingMode sortingMode;

  SquareDayView({Key key, this.minimumDateTime, this.maximumDateTime, this.sortingMode = SortingMode.INCREASING}) : super(key: key) {
    minimumDateTime ??= extractDate(DateTime.now().subtract(Duration(days: 300)));
    maximumDateTime ??= extractDate(DateTime.now().add(Duration(days: 300)));
  }


  @override
  Widget build(BuildContext context) {
    // Storing the relevant dates (between the minimum and maximum ones).
    // TODO : Don't compute this at each builds... A callback for updates from the API ?

    // Map of the events with DateTime from which we only kept the date and not the time.
    Map<DateTime, List<int>> dateEventMap = new Map<DateTime, List<int>>();
    for(DateTime date in gAPI.mappedEventsIndices.keys.toList()) {
      if(date.isBefore(minimumDateTime) || date.isAfter(maximumDateTime))
        continue;

      DateTime extractedDate = extractDate(date);

      if(!dateEventMap.containsKey(extractedDate)) {
        dateEventMap.addAll({extractedDate: new List<int>()});
      }

      dateEventMap[extractedDate] += gAPI.mappedEventsIndices[date];
    }

    List<DateTime> dates = dateEventMap.keys.toList();
    dates.sort((a, b) => (sortingMode == SortingMode.INCREASING) ? a.compareTo(b) : b.compareTo(a)); // Sorting by date decreasing

    return Container(
      margin: EdgeInsets.only(top: 80, left: 5, right: 5),
      child: ListView.builder( // Vertical event list view
        itemCount: dates.length,
        itemBuilder: (BuildContext context, int dateIndex) {
          return Container(
              height: 230,
              width: deviceSize(context).width,
              child: Column(
                children: <Widget>[
                  Row( // Calendar icon + day text row
                    children: <Widget>[

                      // Calendar icon
                      Container(
                        child: const Icon(Icons.calendar_today, color: kPrimaryColor),
                        margin: EdgeInsets.only(left: 10),
                        padding: EdgeInsets.all(5),
                      ),

                      // Day text container
                      Container(
                        width: deviceSize(context).width * 0.6666, // 2/3 of the width
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(
                          top: 5,
                          right: 5,
                          left: 10,
                          bottom: 5
                        ),
                        child: Text(
                          DateFormat("dd/MM EEEE").format(dates[dateIndex]),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontStyle: FontStyle.italic
                          ),
                          textScaleFactor: 2,
                        ),
                      )
                    ],
                  ),

                  _ListDayView(
                    eventIdList: dateEventMap[dates[dateIndex]],
                  )
                  // Actual grid of event for the date pointed buu the item builder index
                ],
              )
          );
        },
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
              // EVENT TAPPED !
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
                            width: 5,
                            style: BorderStyle.solid,
                          ),

                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/event.png"), // EVENT IMAGE URL HERE
                          )
                        )
                      )
                    )
                  ),

                  /* Hovering text */
                  Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.all(15),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: ' ${gAPI.events[eventIdList[index]].title} \n',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 30,
                          backgroundColor: Color(0x66FFFFFF),
                        ),

                        children: <TextSpan>[
                          TextSpan(
                            text: ' ' + gAPI.events[eventIdList[index]].timesToString() + ' ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            )
                          )
                        ]
                      )
                    )
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