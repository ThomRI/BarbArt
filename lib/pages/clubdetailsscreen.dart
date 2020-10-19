import 'package:barbart/api/structures.dart';
import 'package:barbart/components/TextIcon.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class ClubDetailsScreen extends StatefulWidget {
  final AClub club;

  const ClubDetailsScreen({Key key, @required this.club}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _ClubDetailsScreenState();
}

class _ClubDetailsScreenState extends State<ClubDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isMember = gAPI.selfClient.isClubMember(widget.club);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.title),
      ),

      body: ListView(
        children: <Widget>[

          /* Club Image */
          ClipPath(
              clipper: _mainImageClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.club.category == 'BDA' ? AssetImage("assets/header_background_raw.png") : null,
                      fit: BoxFit.cover,
                    )
                ),
              )
          ),

          /* Club title */
          Column(
            children: <Widget>[
              Hero(
                tag: 'clubTitle: ${widget.club.id}',
                child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: ' ${widget.club.title} \n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 30,
                            )
                        )
                    )
                ),
              ),

              /* Club events dates */
              Column(
                children: List.generate(widget.club.permanentEvents.length, (index) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Icon(Icons.calendar_today, color: Colors.black),
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: DateFormat("EEEE").format(widget.club.permanentEvents[index].dateTimeBegin) + " - " + timeToString(widget.club.permanentEvents[index].dateTimeBegin) + '\n',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),

                          children: <InlineSpan>[
                            TextSpan(
                              text: widget.club.permanentEvents[index].location,
                              style: TextStyle(fontSize: 15),
                            )
                          ]
                        ),
                    )
                  ],
                )),
              ),

              /* Club supervisors */
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

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(widget.club.supervisors.length, (index) => TextIcon(
                      icon: const Icon(Icons.person,),
                      text: Text(widget.club.supervisors[index].firstname + " " + widget.club.supervisors[index].lastname),
                    )),
                  )
              ),

              /* "I'm going' / 'I'm not going' notification */
              Container(
                margin: EdgeInsets.only(top: 20),
                child: TextIcon(
                  icon: Icon(Icons.directions_walk, color: isMember ? Colors.green : Colors.grey),
                  text: Text(
                      isMember ? "You're in !" : "You're not a member.",
                      style: TextStyle(
                        color: isMember ? Colors.green : Colors.grey,
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
                child: Text("Description") // TODO : Add actual club description
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