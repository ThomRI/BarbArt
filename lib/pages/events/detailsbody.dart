import 'package:barbart/api/structures.dart';
import 'package:barbart/components/TextIcon.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';

class DetailsBody extends StatefulWidget {
  final AEvent event;

  const DetailsBody({Key key, @required this.event}) : super(key: key);

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
    widget.event.isGoing(
        gAPI.selfClient,
        onConfirmed: (bool going) {
          this.setState(() {
            localGoing = going;
            pending = false;
          });
        }
    );

    widget.event.nbrPeopleGoingNotifier.addListener(() {this.setState(() {});}); // rebuilding when the number of people updated!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // The localGoing state is now the state AT THE MOMENT THE BUTTON WAS PRESSED !

          if(pending) // Do nothing, we are waiting for the server.
            return;

          /* ########################### */
          /* #### HERE GOING ACTION #### */
          /* ########################### */

          // Requesting server, asynchronously with a callback function when we get the response;
          widget.event.setGoing(
            gAPI.selfClient,
            going: !localGoing, // We request the opposite of the current state.
            onConfirmed: (success) {
              if(!success) {
                // Inform the user that there was an error
                Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),

                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(6),
                    ),

                    child: const Text("Can't register ! There are most likely no slots left.", textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ));
              }
              this.setState(() {
                if(success) localGoing = !localGoing;
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
            tag: 'event: ${widget.event.id}',
            child: ClipPath(
              clipper: _mainImageClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: widget.event.image,
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
                tag: 'eventText: ${widget.event.id}',
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: ' ${widget.event.title} \n',
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
                      text: DateFormat("EEEE dd/MM").format(widget.event.dateTimeBegin) + " : " + timeToString(widget.event.dateTimeBegin),
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
                      text: Text(widget.event.nbrPeopleGoingNotifier.value.toString(), style: TextStyle(fontSize: 20)),
                    ),

                    /* Event Place */
                    TextIcon(
                      icon: Icon(Icons.place),
                      text: Text(widget.event.location.toString(), style: TextStyle(fontSize: 20)),
                    ),

                    /* Event number of places available */
                    TextIcon(
                      icon: Icon(Icons.event_seat, color: Colors.brown[400]),
                      text: Text(widget.event.nbrPlaceAvailable.toString(), style: TextStyle(fontSize: 20)),
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
              margin: EdgeInsets.only(top: 20, bottom: 75),
              width: deviceSize(context).width * 0.9,
              child: Text(widget.event.description)
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