import 'package:barbart/constants.dart';
import 'package:flutter/material.dart';
import '../data.dart';
import 'detailsScreenEvent.dart';


class GridViewDaysEvent extends StatelessWidget {
  final List<String> eventName;
  final List<String> eventDate;
  final List<String> eventTime;
  final List<String> eventLocation;
  final List<String> eventPeopleGoing;
  final List<String> eventImage;
  final List<String> eventDescription;

  const GridViewDaysEvent(
      {Key key,
        this.eventName,
        this.eventDate,
        this.eventImage,
        this.eventTime,
        this.eventDescription, this.eventLocation, this.eventPeopleGoing})
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
      final List<String> _eventLocationOfThisDay = <String>[];
      final List<String> _eventPeopleGoingOfThisDay = <String>[];
      final List<String> _eventImageOfThisDay = <String>[];
      final List<String> _eventDescriptionOfThisDay = <String>[];
      do {
        _eventNameOfThisDay.add(eventName[i]);
        _eventTimeOfThisDay.add(eventTime[i]);
        _eventLocationOfThisDay.add(eventLocation[i]);
        _eventPeopleGoingOfThisDay.add(eventPeopleGoing[i]);
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
                            /*decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: new Border.all(
                                color: kPrimaryColor,
                                width: 1,
                                style: BorderStyle.solid,
                              ),
                            ),*/
                            child:Icon(Icons.calendar_today, color: kPrimaryColor,),
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
                            eventLocation: _eventLocationOfThisDay,
                            eventPeopleGoing: _eventPeopleGoingOfThisDay,
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






class GridViewEvent extends StatelessWidget {
  final List<String> eventName;
  final String eventDay;
  final List<String> eventTime;
  final List<String> eventLocation;
  final List<String> eventPeopleGoing;
  final List<String> eventImage;
  final List<String> eventDescription;

  const GridViewEvent(
      {Key key,
      this.eventName,
      this.eventDay,
      this.eventTime,
      this.eventImage,
      this.eventDescription, this.eventLocation, this.eventPeopleGoing})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final children = <Widget>[];
    for (var i = 0; i < eventName.length; i++) {
      children.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                DetailsScreenEvent(eventName[i], eventDay, eventTime[i], eventLocation[i], eventPeopleGoing[i],
                    eventImage[i], eventDescription[i]));
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 5),
            //color: Colors.white,
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      //color: Colors.white,
                      border: new Border.all(
                        color: kBackgroundColor,
                        width: 5,
                        style: BorderStyle.solid,
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(eventImage[i]),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: ' ${eventName[i]} \n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 30,
                        backgroundColor: Color(0x66FFFFFF),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' ${eventTime[i]} ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    return (GridView.count(
      primary: false,
      scrollDirection: Axis.horizontal,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 1,
      children: children,
    ));
  }
}
