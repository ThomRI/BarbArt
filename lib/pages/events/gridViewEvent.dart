import 'package:barbart/constants.dart';
import 'package:flutter/material.dart';
import 'data.dart';
import 'detailsScreen.dart';

class GridViewEvent extends StatelessWidget {
  final List<String> eventName;
  final String eventDay;
  final List<String> eventTime;
  final List<String> eventImage;
  final List<String> eventDescription;

  const GridViewEvent(
      {Key key,
      this.eventName,
      this.eventDay,
      this.eventTime,
      this.eventImage,
      this.eventDescription})
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
                DetailsScreen(eventName[i], eventDay, eventTime[i],
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
