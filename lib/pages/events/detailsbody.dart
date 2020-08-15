import 'package:barbart/components/TextIcon.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';

class DetailsBody extends StatefulWidget {
  final int eventId;

  const DetailsBody({Key key, @required this.eventId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _DetailsBodyState();
}

class _DetailsBodyState extends State<DetailsBody> {
  bool localGoing = false; // true when UI shows that the user is going to the event, false when the user is not going.
  bool pending = false; // If we are still waiting for the server... True by default as there is the going request right at the beginning.

  @override
  void initState() {
    super.initState();

    pending = true;
    /* Fetching if the client is going */
    gAPI.events[widget.eventId].isGoing(
        gAPI.selfClient,
        onConfirmed: (bool going) {
          this.setState(() {
            localGoing = going;
            pending = false;
          });
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // The localGoing state is now the state AT THE MOMENT THE BUTTON WAS PRESSED !

          if(pending) // Do nothing, we are waiting for the server.
            return;

          // Requesting server, asynchronously with a callback function when we get the response;
          gAPI.events[widget.eventId].setGoing(
            gAPI.selfClient,
            going: !localGoing, // We request the opposite of the current state.
            onConfirmed: (success) {
              if(!success) return;
              this.setState(() {
                localGoing = !localGoing;
                pending = false;
              });
            }
          );

          // Setting as pending
          setState(() {
            pending = true;
          });
        },

        child: (pending) ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),) : const Icon(Icons.directions_walk, color: Colors.white),
        backgroundColor: localGoing ? Colors.green : Colors.grey,
      ),

      body: ListView(
        children: <Widget>[

          /* Event Image */
          Hero(
            tag: 'event: ${gAPI.events[widget.eventId].id}',
            child: ClipPath(
              clipper: _mainImageClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: gAPI.events[widget.eventId].image,
                    fit: BoxFit.cover,
                  )
                ),
              )
            )
          ),

          /* Event title */
          Column(
            children: <Widget>[
              Hero(
                tag: 'eventText: ${gAPI.events[widget.eventId].id}',
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: ' ${gAPI.events[widget.eventId].title} \n',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 30,
                      )
                    )
                  )
                ),
              ),

              /* Event date */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 5),
                    child: Icon(Icons.calendar_today, color: Colors.black),
                  ),
                  RichText(
                    text: TextSpan(
                      text: DateFormat("EEEE dd/MM").format(gAPI.events[widget.eventId].dateTimeBegin) + " : " + timeToString(gAPI.events[widget.eventId].dateTimeBegin),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )
                    )
                  )
                ],
              ),

              /* Event infos */
              Container(
                margin: EdgeInsets.only(top: 25),
                padding: EdgeInsets.all(5.0),
                width: deviceSize(context).width * 0.75,
                decoration: BoxDecoration(
                  border: Border(
                    top:    BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid),
                    bottom: BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid),
                  ),
                ),

                /* Row here ! */
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[

                    /* Event number of people going */
                    TextIcon(
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      text: Text(gAPI.events[widget.eventId].nbrPeopleGoing.toString(), style: TextStyle(fontSize: 20)),
                    ),

                    /* Event Place */
                    TextIcon(
                      icon: Icon(Icons.place),
                      text: Text(gAPI.events[widget.eventId].location.toString(), style: TextStyle(fontSize: 20)),
                    ),

                    /* Event number of places available */
                    TextIcon(
                      icon: Icon(Icons.event_seat, color: Colors.deepOrange),
                      text: Text(gAPI.events[widget.eventId].nbrPlaceAvailable.toString(), style: TextStyle(fontSize: 20)),
                    )
                  ],
                )
              ),

              /* "I'm going' / 'I'm not going' notification */
              Container(
                margin: EdgeInsets.only(top: 20),
                child: TextIcon(
                  icon: Icon(Icons.directions_walk, color: (localGoing) ? Colors.green : Colors.grey),
                  text: Text(
                      localGoing ? "I'm going" : "I'm not going",
                    style: TextStyle(
                      color: localGoing ? Colors.green : Colors.grey,
                      fontSize: 20,
                    )
                  ),
                ),
              )
            ],
          ),

          /* Horizontal divider */
          Container(
            margin: EdgeInsets.only(top: 20),
            child: Divider(),
          ),

          /* Description */
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 20),
              width: deviceSize(context).width * 0.9,
              child: Text(gAPI.events[widget.eventId].description)
            ),
          )
        ],
      ),
    );
  }
}

/* Event Image Clipper */
// ignore: camel_case_types
class _mainImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height);
    path.quadraticBezierTo( size.width / 2,
                            size.height - 70,
                            size.width,
                            size.height);
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}