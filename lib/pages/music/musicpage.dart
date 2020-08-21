import 'dart:async';

import 'package:barbart/api/APIValues.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/components/eventregistrationdialog.dart';
import 'package:barbart/components/updatenotifier.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../main.dart';
import '../../utils.dart';

// ignore: must_be_immutable
class MusicPage extends AbstractPageComponent {
  CalendarController _controller = new CalendarController(); // It's important to keep the controller here, so that it is kept between different states

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
  List<FlutterWeekViewEvent> _calendarEvents;
  DateTime _selectedDay;

  Future<void> refresh({Function onDone}) async {
    _selectedDay = (widget._controller.selectedDay ?? extractDate(DateTime.now())).toLocal();

    // Generating flutter internal events
    _calendarEvents = _generateInternalEventList(_selectedDay);

    this.setState(() {
      // Notifier done
      widget.notifier.done();

      if(onDone != null) onDone();
    });
  }

  @override
  void initState() {
    super.initState();

    refresh(); // Async
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 66),

        // Using a stack for the floating button
        child: Stack(
          children: <Widget>[

            /* Main scroll view */
            RefreshIndicator(
              onRefresh: () async {
                gAPI.update(APIFlags.MUSIC_RESERVATIONS, onUpdateDone: () {
                  refresh();
                });
              },

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[

                  /* Table Calendar (date picker) */
                  TableCalendar(
                      calendarController: widget._controller,
                      events: gAPI.mappedMusicRegistrationsIndicesByDay,
                      initialSelectedDay: _selectedDay,
                      startDay: extractDate(DateTime.now()),
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
                        // Refreshing
                        refresh(); // Async
                      }
                  ),

                  /* Actual calendar (day view) */
                  Expanded(
                    child: DayView(
                      date: _selectedDay,
                      events: _calendarEvents,
                      userZoomable: false,
                      inScrollableWidget: true,
                      scrollToCurrentTime: true,
                      style: DayViewStyle(
                        backgroundColor: sameDates(_selectedDay, DateTime.now()) ? Colors.orange.withOpacity(0.1) : Colors.grey[200],
                        hourRowHeight: 40.0,
                        dayBarHeight: 0,
                      ),/*DayViewStyle.fromDate(
                      date: _controller.selectedDay ?? DateTime.now(),
                      currentTimeCircleColor: Colors.pink,
                      dayBarHeight: 0.0,
                      hourRowHeight: 40.0,
                    )*/
                    ),
                  )

                ],
              ),
            ),

            /* Floating Button */
            Positioned(
                bottom: 30,
                right: 10,
                child: FloatingActionButton(
                  backgroundColor: kPrimaryColor,
                  child: const Icon(Icons.add),
                  onPressed: () {
                    EventRegistrationDialog.show(context, day: _selectedDay, title: Text("Time slot"), onConfirmed: (DateTime beginTime, DateTime endTime) {

                      /* ########################################### */
                      /* ###### HERE SLOT REGISTRATION ACTION ###### */
                      /* ########################################### */

                      return gAPI.registerMusicRegistration(
                        gAPI.selfClient,
                        beginTime: beginTime,
                        endTime: endTime,
                        onConfirmed: (registration) {
                          this.setState(() {
                            _calendarEvents.add(_generateInternalEvent(gAPI.musicRegistrations.length - 1)); // Generating last added registration
                          });
                        }
                      );

                    });
                  },
                )
            ),

            /* Update Notifier */
            widget.notifier,

          ],
        )
    );
  }

  FlutterWeekViewEvent _generateInternalEvent(int registrationLocalIndex) {
    AEvent registration = gAPI.musicRegistrations[registrationLocalIndex];
    return new FlutterWeekViewEvent(
        title: gAPI.clientFromUUID(registration.clientUUID).toString(),
        description: registration.description,
        start: registration.dateTimeBegin,
        end: registration.dateTimeEnd,

        backgroundColor: kPrimaryColor.withOpacity(0.5),

        /* Calendar event item content */
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
          if(gAPI.selfClient.uuid != registration.clientUUID) return; // It is not possible to delete a registration that isn't the selfClient's.

          _showEventBottomSheet(
            context,
            registration: registration,
          );
        }
    );
  }

  // Generates events compatible with the internals of flutter_week_view
  List<FlutterWeekViewEvent> _generateInternalEventList(DateTime day) {
    List<FlutterWeekViewEvent> list = new List<FlutterWeekViewEvent>();

    DateTime extracted = extractDate(day); // Wipes out the hour,min,sec
    if(gAPI.mappedMusicRegistrationsIndicesByDay.containsKey(extracted)) {
      gAPI.mappedMusicRegistrationsIndicesByDay[extracted].forEach((index) { // Loop here
        list.add(_generateInternalEvent(index));
      });
    }

    return list;
  }

  void _showEventBottomSheet(BuildContext context, {AEvent registration}) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SingleChildScrollView(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text("Delete slot", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () {

                    /* ####################################### */
                    /* ###### HERE SLOT DELETION ACTION ###### */
                    /* ####################################### */

                    gAPI.deleteMusicRegistration(
                      registration,
                      onConfirmed: () {
                        Navigator.of(bc).pop();


                        // Refreshing
                        // TODO: Only delete the event and don't refresh everything with the server.
                        gAPI.update(APIFlags.MUSIC_RESERVATIONS, onUpdateDone: () {
                          refresh();
                        });
                      }
                    );
                  },
                )
              ],
            ),
          ),
        );
      }
    );
  }

}