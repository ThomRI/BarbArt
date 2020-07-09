import 'package:barbart/components/pagelistheader.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/pages/events/eventspage.dart';
import 'package:barbart/pages/home/homepage.dart';
import 'package:barbart/pages/music/musicpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainBody extends StatelessWidget {
  MainBody({Key key}) : super(key: key);

  final m_headerKey = new GlobalKey<_PageListBodyState>();
  PageListHeader m_header = new PageListHeader();
  PageListBody m_body = new PageListBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: 230,
          pinned: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(m_header.getPageListWidget.height),
            child: m_header.getPageListWidget
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: m_header,
            collapseMode: CollapseMode.parallax,

          ),
        ),

        SliverList(
          delegate: SliverChildListDelegate([
            PageListBody(),
          ]
          ),
        ),

      ],
    );
  }
}

class PageListBody extends StatefulWidget {

  PageListBody({Key key}) : super(key: key);

  @override
  _PageListBodyState createState() => new _PageListBodyState();

}

class _PageListBodyState extends State<PageListBody> {
  int currentIndex = 0;

  List pagesList = [HomePage(), EventsPage(), MusicPage()];

  @override
  Widget build(BuildContext context) {
   return Container(
     height: MediaQuery.of(context).size.height,
     child: PageView(
       pageSnapping: true,
       children: <Widget>[
         HomePage(),
         EventsPage(),
         MusicPage(),
       ],

       onPageChanged: (int index) {
         setState(() {
           currentIndex = index;
         });
       },
     ),

   );
  }
}

