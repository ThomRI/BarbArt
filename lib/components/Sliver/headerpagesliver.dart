import 'package:barbart/physics/interruptible_scroll_physics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../utils.dart';
import '../pagelistheader.dart';

/// Used to interact with callback functions
enum SliverActions {
  Collapse,         // Collapse the FlexibleSpaceBar
  Expand,           // Expand the FlexibleSpaceBar
  None,             // Do nothing

  CollapseAndStay,  // Collapses and forbid the expansion
  ExpandAndStay,    // Expands and forbids to collapse
}

/// This class's purpose is to represent a full body page with a header containing a custom logo and a page list that can be scrolled underneath.
/// It should be highly configurable, but is not for now.
/// TODO : Add configuration possibilities.
/// TODO : Warning : Problem of animation when selecting page from header. Works well with every page but the second one which jumps directly to the corresponding page!
// ignore: must_be_immutable
class HeaderPageSliver extends StatefulWidget {
  final List pagesList;
  final SliverActions Function(int index) onPageChanged; // Should return a SliverAction
  final Function(double scrollValue) onPageScroll; // Called when the page view is scrolling between pages
  final bool headerFollowFirstPage;

  PageListHeader m_header = new PageListHeader();

  HeaderPageSliver({
    Key key,
    @required this.pagesList,
    @required this.onPageChanged,         // Page changed callback
    @required this.onPageScroll,          // Page scrolled callback
    this.headerFollowFirstPage  = false,  // Should the header pop when going back to first page ?
  }) : super(key: key) {
    m_header.pagesList = pagesList;
  }

  @override
  HeaderPageSliverState createState() => HeaderPageSliverState();
}

class HeaderPageSliverState extends State<HeaderPageSliver> {
  final headerPageListKey = new GlobalKey<PageListState>();
  final bodyPageListKey = new GlobalKey<PageListBodyState>();

  bool verticalScrollEnabled = true;

  ScrollController controller = new ScrollController();


  @override
  void initState() {
    super.initState();
  }

  void _collapse({Duration duration = kDefaultTransitionDuration}) {
    controller.animateTo(deviceSize(context).height * HEADER_HEIGHT_SCREEN_RATIO, duration: duration, curve: Curves.easeIn);
  }

  void _expand({Duration duration = kDefaultTransitionDuration}) {
    controller.animateTo(0.0, duration: duration, curve: Curves.easeIn);
  }

  void _enableScrolling() {
    verticalScrollEnabled = true;
  }

  void _disableScrolling() {
    verticalScrollEnabled = false;
  }

  void _handlePageChangedCallback() {
    switch(this.widget.onPageChanged(headerPageListKey.currentState.selectedIndex)) { // Calling the onPageChanged callback of the HeaderPageSliver
      case SliverActions.Collapse: {
        _collapse();
        setState(() { // Change in physics so must update state !
          _enableScrolling();
        });
      } break;

      case SliverActions.Expand: {
        _expand();
        setState(() { // Change in physics so must update state !
          _enableScrolling();
        });
      } break;

      case SliverActions.CollapseAndStay: {
        _collapse();
        setState(() { // Change in physics so must update state !
          _disableScrolling();
        });
      } break;

      case SliverActions.ExpandAndStay: {
        _expand();
        setState(() { // Change in physics so must update state !
          _disableScrolling();
        });

      } break;

      case SliverActions.None: {
        // Do nothing
      } break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(

      /* Back button override */
      onWillPop: () async {
        if(bodyPageListKey.currentState.currentIndex == 0) return true; // Don't override if already on the first page

        bodyPageListKey.currentState.controller.animateToPage(0, duration: kDefaultTransitionDuration, curve: Curves.easeIn);
        return false;
      },


      child: CustomScrollView(
        controller: controller,
        physics: (verticalScrollEnabled) ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),

        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: deviceSize(context).height * HEADER_HEIGHT_SCREEN_RATIO,
            pinned: true, // Whether or not the header should always be shown (in its minimized form)
            floating: false, // Show the header each time we scroll back up (instead of waiting the top of the page)
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(10),
              child: PageList(
                key: headerPageListKey,
                onSelectionChanged: () { /* SELECTION CHANGED IN THE HEADER */
                  bodyPageListKey.currentState.controller.jumpToPage(headerPageListKey.currentState.selectedIndex);

                  _handlePageChangedCallback();
                },

                pagesList: widget.pagesList,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.m_header,
              collapseMode: CollapseMode.parallax,
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              PageListBody(
                key: bodyPageListKey,
                onPageChanged: () { /* PAGE CHANGED IN THE BODY */
                  headerPageListKey.currentState.setState(() {
                    headerPageListKey.currentState.selectedIndex = bodyPageListKey.currentState.currentIndex;
                    headerPageListKey.currentState.displayIndex = bodyPageListKey.currentState.currentIndex;

                    _handlePageChangedCallback();
                  });
                },

                pagesList: widget.pagesList,

                onScroll: (double scrollValue) {
                  if(widget.headerFollowFirstPage && scrollValue <= 1.0) {
                    controller.jumpTo(deviceSize(context).height * HEADER_HEIGHT_SCREEN_RATIO * scrollValue);
                  }

                  widget.onPageScroll(scrollValue); // Calling the provided callback.
                },
              ),
            ]
            ),
          ),

        ],
      ),
    );
  }
}

class PageListBody extends StatefulWidget {
  final Function onPageChanged;
  final List pagesList;

  final Function(double value) onScroll;

  PageListBody({Key key, this.onPageChanged, this.pagesList, @required this.onScroll}) : super(key: key);

  @override
  PageListBodyState createState() => new PageListBodyState();

}

class PageListBodyState extends State<PageListBody> {
  int currentIndex = 0;

  PageController controller;

  @override
  void initState() {
    super.initState();

    controller = PageController(initialPage: 0);
    controller.addListener(() {
      widget.onScroll(controller.page); // controller.page is in range [0.0; nbr of pages - 1] and is a DOUBLE that is interpolated between pages when scrolling (pseudo-continuous values between 0 and 1 for scrolling between the first and second page for example).
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: PageView.builder(
        //physics: BouncingScrollPhysics(), // Just nicer in general
        controller: controller,
        pageSnapping: true,
        itemBuilder: (context, index) => widget.pagesList[index],

        itemCount: widget.pagesList.length,

        onPageChanged: (int index) {
          setState(() {
            currentIndex = index;
            widget.onPageChanged();
          });
        },
      ),

    );
  }
}

