import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../main.dart';
import '../utils.dart';

// ignore: must_be_immutable
class PageListHeader extends StatefulWidget {

  List pagesList;

  PageListHeader({Key key, this.pagesList}) : super(key: key);

  @override
  _PageListHeaderState createState() => _PageListHeaderState();
}

class _PageListHeaderState extends State<PageListHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBackgroundColor,
      child: Container(

        /* Background image */
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.elliptical(100.0, 10.0),
            bottomLeft: Radius.elliptical(100.0, 10.0)
          ),

          image:  DecorationImage(
            image: AssetImage("assets/header_background_raw.png"),
            fit: BoxFit.cover,
          ),
        ),

        child: Stack(
          children: <Widget>[

            /* Settings icon */
            /*Positioned(
              right: 0,
              child: IconButton(
                alignment: Alignment.topRight,
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  return; // TODO: Create the setting page !
                  Navigator.of(context).pushNamed('/settings');
                },
              ),
            ),*/


            /* Avatar */
            Positioned(
              left: 10,
              top: 10,
              child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).pushNamed('/profile');
                  this.setState(() { });
                },

                child: Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5.0)
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundImage: gAPI.selfClient.avatar,
                        backgroundColor: kDefaultCircleAvatarBackgroundColor,
                        radius: 15.0,
                      ),

                      Container(
                        margin: EdgeInsets.only(left: 5.0),
                        child: Text(
                          gAPI.selfClient.firstname,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ),

            /* Centered logo */
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 35),
                  child: Image(
                    image: AssetImage("assets/logo_clipped.png"),
                    fit: BoxFit.cover,
                    width: deviceSize(context).height * HEADER_HEIGHT_SCREEN_RATIO * 0.6, // 60% of the header size
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0, size.height - kDefaultCurveShift);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - kDefaultCurveShift);
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PageList extends StatefulWidget {
  final double m_height = 30;
  double get height => m_height;

  final Function onSelectionChanged;
  final List pagesList;

  PageList({Key key, this.onSelectionChanged, this.pagesList}) : super(key: key);

  @override
  PageListState createState() => new PageListState();
}

class PageListState extends State<PageList> {
  int selectedIndex = 0,
      displayIndex = 0;

  final itemSize = 20.0;

  ScrollController scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container( // CONTAINER PAGE LIST
      height: widget.m_height,
      //margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
      margin: EdgeInsets.only(bottom: 20),

      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.pagesList.length,
        itemBuilder: (context, index) => GestureDetector( // LIST BUILDER HERE
          onTap: () {
            setState(() {
              selectedIndex = index;
            });

            widget.onSelectionChanged();
          },
          child: Container( // CLICKABLE ITEM CONTAINER
            alignment: Alignment.center,
            margin: EdgeInsets.symmetric(horizontal: deviceSize(context).width / 20),
            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),

            decoration: BoxDecoration(
              color: index == displayIndex ? Colors.white.withOpacity(0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),


            child: Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ // ITEM CONTENT HERE
                Container(
                  margin: EdgeInsets.only(right: 3),
                  child: widget.pagesList[index].icon,
                ),

                // Uncomment to show page name
                Visibility(
                  visible: (selectedIndex == index),
                  child: Text(
                      widget.pagesList[index].name,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),


          ),
        ),
      ),
    );
  }
}