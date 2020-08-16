import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../main.dart';
import '../../utils.dart';

class MusicPage extends StatefulWidget implements AbstractPageComponent {
  @override
  String get name => "Salle musique";

  @override
  Icon get icon => Icon(Icons.music_note, color: Colors.white);

  @override
  Icon get logo => Icon(Icons.music_note, color: Colors.white, size: 100);

  @override
  State<StatefulWidget> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  CalendarController _controller;
  List<FlutterWeekViewEvent> _calendarEvents;

  @override
  void initState() {
    super.initState();

    // Init things here
    _controller = new CalendarController();

    _calendarEvents = _generateInternalEventList(DateTime.now());
  }

  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  List<FlutterWeekViewEvent> _generateInternalEventList(DateTime day) {
    List<FlutterWeekViewEvent> list = List<FlutterWeekViewEvent>();

    DateTime extracted = extractDate(day); // Wipes out the hour,min,sec
    if(gAPI.mappedMusicReservationsIndicesByDay.containsKey(extracted)) {
      gAPI.mappedMusicReservationsIndicesByDay[extracted].forEach((index) {
        list.add(new FlutterWeekViewEvent(
            title: gAPI.clientFromUUID(gAPI.musicReservations[index].clientUUID).toString(),
            description: gAPI.musicReservations[index].description,
            start: gAPI.musicReservations[index].dateTimeBegin,
            end: gAPI.musicReservations[index].dateTimeEnd,

            backgroundColor: kPrimaryColor.withOpacity(0.5),
            eventTextBuilder: (event, context, dayView, height, width) => Row(
              children: <Widget>[
                Text(
                  event.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Expanded(
                  child: Text(
                    timeToString(event.start) + " - " + timeToString(event.end),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey[200],
                      fontWeight: FontWeight.bold,
                    )
                  )
                )
              ],
            ),

            onTap: () {
              // TODO: Implement music calendar event onTap()
            }
        ));
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 70),

      // Using a stack for the floating button
      child: Stack(
        children: <Widget>[

          /* Main scroll view */
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              /* Table Calendar (date picker) */
              TableCalendar(
                calendarController: _controller,

                events: gAPI.mappedMusicReservationsIndicesByDay,
                initialCalendarFormat: CalendarFormat.week,
                calendarStyle: CalendarStyle(
                  canEventMarkersOverflow: true,
                  todayColor: Colors.orange,
                  selectedColor: kPrimaryColor,
                  todayStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    color: Colors.white
                  ),
                ),

                headerStyle: HeaderStyle(
                  centerHeaderTitle: true,

                  /* View format selector decoration */
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20.0),
                  ),

                  formatButtonTextStyle: TextStyle(color: Colors.white),
                  formatButtonShowsNext: false,
                ),

                startingDayOfWeek: StartingDayOfWeek.monday,

                /* Header day selection callback */
                onDaySelected: (date, eventsList) {
                  // Updating the selected events indices list to update the listview
                  this.setState(() {
                    _calendarEvents = _generateInternalEventList(_controller.selectedDay ?? DateTime.now());
                  });
                }
              ),

              /* Actual calendar (day view) */
              Expanded(
                child: DayView(
                  date: _controller.selectedDay ?? DateTime.now(),
                  events: _calendarEvents,
                  style: DayViewStyle.fromDate(
                    date: _controller.selectedDay ?? DateTime.now(),
                    currentTimeCircleColor: Colors.pink,
                    dayBarHeight: 0.0,
                    hourRowHeight: 40.0,
                  )
                ),
              )

            ],
          ),

          /* Floating Button */
          Positioned(
            bottom: 50,
            right: 10,
            child: FloatingActionButton(
              backgroundColor: kPrimaryColor,
              child: const Icon(Icons.add),
              onPressed: () {
                // TODO: Implement music page floating button onPressed()
              },
            )
          )

        ],
      )
    );
  }
  
}