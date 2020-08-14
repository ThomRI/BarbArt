import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/components/ControlledCarousel.dart';
import 'package:barbart/pages/clubs/clubspage.dart';
import 'package:barbart/pages/events/eventspage.dart';
import 'package:barbart/pages/home/homepage.dart';
import 'package:barbart/pages/music/musicpage.dart';
import 'package:barbart/screens/settings/settingsscreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../utils.dart';

class PageListHeader extends StatelessWidget {

  List pagesList;
  bool _admin = true;

  PageListHeader({Key key, this.pagesList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipPath(
        clipper: _MainClipper(),

        child: Container(
          child: Stack(
            children: <Widget>[
              _admin ? Positioned(
                right: 0,
                child: IconButton(
                  alignment: Alignment.topRight,
                  icon: Icon(Icons.settings, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                ),
              ): Container(),
              Positioned(
                child: IconButton(
                  alignment: Alignment.topLeft,
                  icon: Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/profile');
                  },
                ),
              ),

              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(top: dp(context, 10)),
                    child: ControlledCarousel(
                      enabled: true,
                      itemList: pagesList.map((page) => Container(
                        child: page.logo,
                      )).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            image:  DecorationImage(
              image: AssetImage("assets/header_background_raw.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),

      decoration: BoxDecoration(
        color: AbstractPageComponent.backgroundColor,
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
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[ // ITEM CONTENT HERE
                widget.pagesList[index].icon,

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
            margin: EdgeInsets.symmetric(horizontal: dp(context, kDefaultPadding / 6)),
            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),

            decoration: BoxDecoration(
              color: index == displayIndex ? Colors.white.withOpacity(0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),

          ),
        ),
      ),
    );
  }
}