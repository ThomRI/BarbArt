import 'package:barbart/constants.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'gridViewEvent.dart';
import 'myClipper.dart';

class GridViewDays extends StatelessWidget {
  final List<String> eventName;
  final List<String> eventDate;
  final List<String> eventTime;
  final List<String> eventImage;
  final List<String> eventDescription;

  const GridViewDays(
      {Key key,
      this.eventName,
      this.eventDate,
      this.eventImage,
      this.eventTime,
      this.eventDescription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final children = <Widget>[];

    int i = 0;

    while (i < eventDate.length) {
      String day = eventDate[i];
      final List<String> _eventNameOfThisDay = <String>[];
      final List<String> _eventTimeOfThisDay = <String>[];
      final List<String> _eventImageOfThisDay = <String>[];
      final List<String> _eventDescriptionOfThisDay = <String>[];
      do {
        _eventNameOfThisDay.add(eventName[i]);
        _eventTimeOfThisDay.add(eventTime[i]);
        _eventImageOfThisDay.add(eventImage[i]);
        _eventDescriptionOfThisDay.add(eventDescription[i]);
        i += 1;
      } while (i < eventDate.length && eventDate[i].split(",")[0] == day);

      children.add(
        Container(
          padding: EdgeInsets.only(top: 10),
          child: Stack(
            children: <Widget>[
              Container(
                height: 230,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,

                      child: Row(
                        children: <Widget>[
                          Container(
                            margin:EdgeInsets.only(left: 10),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: new Border.all(
                                color: kPrimaryColor,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child:Icon(Icons.calendar_today),
                          ),
                          Container(
                            width: size.width*2/3,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(top: 5, right: 5, left: 10, bottom:5),
                            decoration: BoxDecoration(

                              borderRadius: BorderRadius.circular(20),
                              //color: kPrimaryColor,
                            ),
                            child: Text(
                              day.substring(0, 1).toUpperCase() + day.substring(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: kPrimaryColor,fontStyle: FontStyle.italic, ),
                              textScaleFactor: 2,
                            ),
                          ),
                        ],
                      ),

                    ),


                    Stack(
                      children: <Widget>[
                        Container(
                          //color: Colors.green,
                          height: 170,
                          child: GridViewEvent(
                            eventName: _eventNameOfThisDay,
                            eventImage: _eventImageOfThisDay,
                            eventDay: day,
                            eventTime: _eventTimeOfThisDay,
                            eventDescription: _eventDescriptionOfThisDay,
                          ),
                          //margin: EdgeInsets.all(10),
                          padding:
                              EdgeInsets.only(bottom: 5, right: 5, left: 5, top: 5),
                        ),
                        Container(
                          height: 170,
                          //color: Colors.red,
                          alignment: Alignment.centerRight,
                          width: size.width,
                          child: Icon(
                            Icons.arrow_right,
                            color: primary_color_dark,
                            size: (_eventNameOfThisDay.length >= 3) ? 85 : 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return (ListView(
      children: children,
    ));
  }
}
