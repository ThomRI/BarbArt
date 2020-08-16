import 'package:barbart/components/Sliver/headerpagesliver.dart';
import 'package:barbart/pages/clubs/clubspage.dart';
import 'package:barbart/pages/events/eventspage.dart';
import 'package:barbart/pages/home/homepage.dart';
import 'package:barbart/pages/music/musicpage.dart';
import 'package:flutter/material.dart';

class MainBody extends StatelessWidget {
  MainBody({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HeaderPageSliver(
        pagesList: [HomePage(), EventsPage(), MusicPage(), ClubsPage()],

        onPageChanged: (int index) {
          if(index == 0)  return SliverActions.ExpandAndStay;
          else            return SliverActions.CollapseAndStay;
        },

        onPageScroll: (double scrollValue) { },

        headerFollowFirstPage: true,
      ),
    );
  }
}

