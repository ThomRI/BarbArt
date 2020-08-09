import 'dart:math';

import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'dart:convert';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// ignore: must_be_immutable
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

class _MusicPageState extends State<MusicPage>{

  CalendarController _controller;
  Map<DateTime, List<dynamic>> _events;
  List<dynamic> _selectedEvents;
  TextEditingController _eventController;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _eventController = TextEditingController();
    _events = {};
    _selectedEvents = [];
    initPrefs();
  }

  void dispose(){
    super.dispose();
    _controller.dispose();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  GlobalKey<ScaffoldState> musicPageScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: musicPageScaffoldKey,
      body: Container(
        height: MediaQuery.of(context).size.height-130,
        margin: EdgeInsets.only(top: 70),
        child: Stack(
          children: <Widget> [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TableCalendar(
                    events: _events,
                    initialCalendarFormat: CalendarFormat.week,
                    calendarStyle: CalendarStyle(
                        canEventMarkersOverflow: true,
                        todayColor: Colors.orange,
                        selectedColor: Theme.of(context).primaryColor,
                        todayStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.white)),
                    headerStyle: HeaderStyle(
                      centerHeaderTitle: true,
                      formatButtonDecoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      formatButtonTextStyle: TextStyle(color: Colors.white),
                      formatButtonShowsNext: false,
                    ),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onDaySelected: (date, events) {
                      setState(() {
                        _selectedEvents = events;
                      });
                    },
                    builders: CalendarBuilders(
                      selectedDayBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                      todayDayBuilder: (context, date, events) => Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                    calendarController: _controller,
                  ),
                  ..._selectedEvents.map((event) => Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(DateTime.parse(event["startTime"]).hour.toString() + "h" +
                                ((DateTime.parse(event["startTime"]).minute>=10) ? DateTime.parse(event["startTime"]).minute.toString() : "0"+DateTime.parse(event["startTime"]).minute.toString())),
                            Container(
                              height: 50,
                              width: 1,
                              color: Colors.grey,
                            ),
                            Text(DateTime.parse(event["endTime"]).hour.toString() + "h" +
                                ((DateTime.parse(event["endTime"]).minute>=10) ? DateTime.parse(event["endTime"]).minute.toString() : "0"+DateTime.parse(event["endTime"]).minute.toString()))
                          ],
                        ),
                        Text(
                          event["title"]
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.grey),
                          onPressed: (){
                            setState(() {
                              _events[_controller.selectedDay].remove(event);
                              _selectedEvents = _events[_controller.selectedDay];
                              prefs.setString("events", json.encode(encodeMap(_events)));
                            });
                          },
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              right:30,
              child: FloatingActionButton(
                backgroundColor: kPrimaryColor,
                child: Icon(Icons.add),
                onPressed: _showAddDialog,
              ),
            ),
          ]
        ),
      ),
    );
  }

  _showAddDialog() async {
    DateTime _startTime = DateTime(_controller.selectedDay.year, _controller.selectedDay.month, _controller.selectedDay.day, 12, 0);
    DateTime _endTime = DateTime(_controller.selectedDay.year, _controller.selectedDay.month, _controller.selectedDay.day, 12, 0);


    final GlobalKey<_RowTimePickerState> startKey = GlobalKey<_RowTimePickerState>();
    final GlobalKey<_RowTimePickerState> endKey = GlobalKey<_RowTimePickerState>();

    bool validTime(DateTime start, DateTime end, List<dynamic> _eventsOfTheDay){
      if (_eventsOfTheDay == null){
        return true;
      }
      if (end.compareTo(start) != 1){
        return false;
      }
      for (dynamic _event in _eventsOfTheDay){
        print(end);
        print(_event["startTime"]);
        if (!(start.compareTo(DateTime.parse(_event["startTime"])) == -1
            && (end.compareTo(DateTime.parse(_event["startTime"])) !=1)
        || start.compareTo(DateTime.parse(_event["endTime"])) != -1
            && end.compareTo(DateTime.parse(_event["endTime"])) == 1)){
          return false;
        }
      }
      return true;
    }

    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            height: min(200, MediaQuery.of(context).size.height),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: <Widget>[
                      Text('Title'),
                      TextField(
                          controller: _eventController,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20),
                          ]
                      ),
                    ],
                  )
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      RowTimePicker(key: startKey, time: _startTime, title: "Start at ",),
                      RowTimePicker(key: endKey, time: _endTime, title: "End at ",),
                    ],
                  ),
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                _eventController.clear();
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Save"),
              onPressed: () {
                if (_eventController.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: 'No title',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white
                  );
                  return;
                }
                _startTime = startKey.currentState.time;
                _endTime = endKey.currentState.time;
                if (validTime(_startTime, _endTime, _events[_controller.selectedDay])){
                  Map<String, String> dictEvent = {'title': _eventController.text, 'startTime': _startTime.toString(), 'endTime':_endTime.toString()};
                  if (_events[_controller.selectedDay] != null) {
                    _events[_controller.selectedDay].add(dictEvent);
                  } else {
                    _events[_controller.selectedDay] = [dictEvent];
                  }
                  _events[_controller.selectedDay].sort((x, y) => (x["startTime"].compareTo(y["startTime"])));
                  prefs.setString("events", json.encode(encodeMap(_events)));
                  _eventController.clear();
                  Navigator.pop(context);
                  setState(() {
                    _selectedEvents = _events[_controller.selectedDay];
                  });
                }
                else {
                  Fluttertoast.showToast(
                      msg: 'Invalid period of time',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white
                  );
                }

              },
            )
          ],
        ));
  }
}

// ignore: must_be_immutable
class RowTimePicker extends StatefulWidget{

  DateTime time;
  String title;

  RowTimePicker({Key key, this.time, this.title}) : super(key : key);

  @override
  State<StatefulWidget> createState() => _RowTimePickerState();

}

class _RowTimePickerState extends State<RowTimePicker>{

  DateTime time;

  void initState(){
    super.initState();
    time = widget.time;
    print(widget.key);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(widget.title ?? ""),
            FlatButton(
              child: Text(time.hour.toString() + "h" + ((time.minute>=10) ? time.minute.toString() : "0"+time.minute.toString()) ?? ""),
              onPressed: () {
                DatePicker.showTimePicker(context, showTitleActions: true, showSecondsColumn: false,
                    onChanged: (date) {
                      print('change $date in time zone ' + date.timeZoneOffset.inHours.toString());
                    },
                    onConfirm: (date) {
                      print('confirm start $date');
                      setState(() {
                        time = date;
                      });
                    },
                    currentTime: time);
              },
            ),
          ],

    );
  }

}