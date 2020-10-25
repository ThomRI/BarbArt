import 'package:barbart/constants.dart';
import 'package:flutter/material.dart';
import '../data.dart';
import 'detailsScreenEvent.dart';


class ListViewDaysEvent extends StatelessWidget {
  final Map<String, List<int>> eventDates;

  const ListViewDaysEvent(
      {Key key, this.eventDates}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    MediaQueryData deviceInfo = MediaQuery.of(context);
    final size = deviceInfo.size;
    final orientation = deviceInfo.orientation;
    final dPRatio = deviceInfo.devicePixelRatio;

    return (ListView.builder(

      itemCount: eventDates.keys.length,

      itemBuilder: (BuildContext context, int index){
        String day = eventDates.keys.toList()[index];
        return Container(
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
                            day : day,
                            eventsIdsOfThisDay: eventDates[day],
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
                            size: (eventDates[day].length >= 3) ? 85 : 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ));
  }
}

class GridViewEvent extends StatelessWidget {

  final List<int> eventsIdsOfThisDay;
  final String day;

  const GridViewEvent(
      {Key key, this.eventsIdsOfThisDay, this.day}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String _eventName, _eventTime, _eventLocation, _eventPeopleGoing,
    _eventImage, _eventDescription;

    return (GridView.builder(
      primary: false,
      scrollDirection: Axis.horizontal,

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 10,
      ),

      itemCount: eventsIdsOfThisDay.length,

      itemBuilder: (BuildContext context, int i){
        Map<String, String> dictEvent = events[eventsIdsOfThisDay[i]];
        _eventName = dictEvent['name'];
        _eventTime = dictEvent['time'];
        _eventImage = dictEvent['image'];

        return GestureDetector(

          onTap: () {
            Map<String, String> dictEvent = events[eventsIdsOfThisDay[i]];
            _eventName = dictEvent['name'];
            _eventTime = dictEvent['time'];
            _eventLocation = dictEvent['location'];
            _eventPeopleGoing = dictEvent['numberOfPeopleGoing'];
            _eventImage = dictEvent['image'];
            _eventDescription = dictEvent['description'];
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailsScreenEvent(_eventName, day, _eventTime, _eventLocation, _eventPeopleGoing,
                    _eventImage, _eventDescription)));
          },
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 5),
            //color: Colors.white,
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Hero(
                    tag: '$day $_eventTime',
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
                          image: AssetImage(_eventImage),
                        ),
                      ),
                    ),
                  )
                ),
                Container(
                  alignment: Alignment.center,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: ' $_eventName \n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 30,
                        backgroundColor: Color(0x66FFFFFF),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' $_eventTime ',
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
        );
      },
    ));
  }
}