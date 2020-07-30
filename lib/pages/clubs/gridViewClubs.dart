import 'package:barbart/constants.dart';
import 'package:flutter/material.dart';
import '../data.dart';
import'./detailsScreenClub.dart';


class GridViewClubs extends StatelessWidget {
  final List<String> clubNameEvent;
  final List<String> clubName;
  final List<String> clubDate;
  final List<String> clubTime;
  final List<String> clubLocation;
  final List<String> clubSeatsTotal;
  final List<String> clubSeatsLeft;
  final List<String> clubImage;
  final List<String> clubDescription;

  const GridViewClubs(
      {Key key,
        this.clubNameEvent,
        this.clubName,
        this.clubDate,
        this.clubImage,
        this.clubTime,
        this.clubLocation,
        this.clubSeatsTotal,
        this.clubSeatsLeft,
        this.clubDescription,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final children = <Widget>[];

    int i = 0;

    while (i < clubDate.length) {
      String day = clubDate[i];
      final List<String> _clubNameEventOfThisDay = <String>[];
      final List<String> _clubNameOfThisDay = <String>[];
      final List<String> _clubTimeOfThisDay = <String>[];
      final List<String> _clubLocationOfThisDay = <String>[];
      final List<String> _clubSeatsTotalOfThisDay = <String>[];
      final List<String> _clubSeatsLeftOfThisDay = <String>[];
      final List<String> _clubImageOfThisDay = <String>[];
      final List<String> _clubDescriptionOfThisDay = <String>[];
      do {
        _clubNameEventOfThisDay.add(clubNameEvent[i]);
        _clubNameOfThisDay.add(clubName[i]);
        _clubTimeOfThisDay.add(clubTime[i]);
        _clubLocationOfThisDay.add(clubLocation[i]);
        _clubSeatsTotalOfThisDay.add(clubSeatsTotal[i]);
        _clubSeatsLeftOfThisDay.add(clubSeatsLeft[i]);
        _clubImageOfThisDay.add(clubImage[i]);
        _clubDescriptionOfThisDay.add(clubDescription[i]);
        i += 1;
      } while (i < clubDate.length && clubDate[i].split(",")[0] == day);

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
                          child: GridViewClub(
                            clubNameEvent: _clubNameEventOfThisDay,
                            clubName: _clubNameOfThisDay,
                            clubImage: _clubImageOfThisDay,
                            clubDay: day,
                            clubTime: _clubTimeOfThisDay,
                            clubLocation: _clubLocationOfThisDay,
                            clubSeatsTotal: _clubSeatsTotalOfThisDay,
                            clubSeatsLeft: _clubSeatsLeftOfThisDay,
                            clubDescription: _clubDescriptionOfThisDay,
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
                            size: (_clubNameOfThisDay.length >= 3) ? 85 : 0,
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






class GridViewClub extends StatelessWidget {
  final List<String> clubNameEvent;
  final List<String> clubName;
  final String clubDay;
  final List<String> clubTime;
  final List<String> clubLocation;
  final List<String> clubSeatsTotal;
  final List<String> clubSeatsLeft;
  final List<String> clubImage;
  final List<String> clubDescription;

  const GridViewClub(
      {Key key,
      this.clubNameEvent,
      this.clubName,
      this.clubDay,
      this.clubTime,
      this.clubLocation,
      this.clubSeatsTotal,
      this.clubSeatsLeft,
      this.clubImage,
      this.clubDescription})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final children = <Widget>[];
    for (var i = 0; i < clubName.length; i++) {
      children.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                DetailsScreenClub(clubNameEvent[i], clubName[i], clubDay, clubTime[i], clubLocation[i], clubSeatsTotal[i],
                    clubSeatsLeft[i], clubImage[i], clubDescription[i]));
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
                        image: AssetImage(clubImage[i]),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: ' ${clubName[i]} \n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                        fontSize: 30,
                        backgroundColor: Color(0x66FFFFFF),
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' ${clubNameEvent[i]} \n',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: ' ${clubTime[i]} ',
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
