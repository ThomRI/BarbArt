import 'package:barbart/pages/events/eventspage.dart';
import 'package:barbart/pages/home/homepage.dart';
import 'package:barbart/pages/music/musicpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class PageListHeader extends StatelessWidget {

  _PageList pageListWidget = new _PageList();
  _PageList get getPageListWidget => pageListWidget;

  List pagesList = [HomePage(), EventsPage(), MusicPage()];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipPath(
        clipper: _MainClipper(),

        child: Container(
          child: Column(
            children: <Widget>[
              /* ### LOGO ### */
              Container(
                child: Center(
                  child: Image(
                    image: AssetImage("assets/logo.png"),
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
            ],
          ),

          decoration: BoxDecoration(
            color: kPrimaryColor,
          ),
        ),
      ),

      decoration: BoxDecoration(
        color: kBackgroundColor,
      ),
    );
  }

}

class _MainClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = new Path();

    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, size.height - 20, size.width, size.height);
    path.lineTo(size.width, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _PageList extends StatefulWidget {
  final double m_height = 30;
  double get height => m_height;

  @override
  _PageListState createState() => new _PageListState();
}

class _PageListState extends State<_PageList> {
  int selectedIndex = 0;

  List pagesList = [HomePage(), EventsPage(), MusicPage()];

  @override
  Widget build(BuildContext context) {
    return Container( // CONTAINER PAGE LIST
      height: widget.m_height,
      //margin: EdgeInsets.symmetric(vertical: kDefaultPadding),
      margin: EdgeInsets.only(bottom: 20),

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pagesList.length,
        itemBuilder: (context, index) => GestureDetector( // LIST BUILDER HERE
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
          },
          child: Container( // CLICKABLE ITEM CONTAINER
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[ // ITEM CONTENT HERE
                pagesList[index].icon,

                Text(
                    pagesList[index].name,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                ),
              ],
            ),
            margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
            padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),

            decoration: BoxDecoration(
              color: index == selectedIndex ? Colors.white.withOpacity(0.4) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),

          ),
        ),
      ),
    );
  }

}
Container _buildPagesList() {

}