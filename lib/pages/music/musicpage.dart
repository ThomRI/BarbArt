import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../main.dart';

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
  List<int> _selectedEventsIndices;

  @override
  Widget build(BuildContext context) {
    /* Creating Flutter Week View compatible events */
    List<FlutterWeekViewEvent> _calendarEvents = List<FlutterWeekViewEvent>();



    return Container(
      margin: EdgeInsets.only(top: 70),

      // Using a stack for the floating button
      child: Stack(
        children: <Widget>[

          /* Main scroll view */
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                /* Table Calendar (date picker) */
                TableCalendar(
                  calendarController: _controller,

                  events: gAPI.mappedEventsIndices,
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
                      _selectedEventsIndices = eventsList;
                    });
                  }
                ),

                /* Actual calendar (day view) */
                DayView(
                  date: _controller.selectedDay ?? DateTime.now(),

                )

              ],
            )
          )

        ],
      )
    );
  }
  
}