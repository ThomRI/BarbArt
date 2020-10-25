import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barbart/api/APIValues.dart';
import 'package:barbart/api/structures.dart';
import 'package:barbart/components/routing/FadePageRoute.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../utils.dart';
import 'detailsscreen.dart';

enum SortingMode {
  INCREASING,
  DECREASING
}

// ignore: must_be_immutable
class SquareDayView extends StatefulWidget {
  DateTime  minimumDateTime, maximumDateTime;

  final SortingMode sortingMode;
  final bool weekDistinction; // Only this week is colored, the rest is in gray

  List<AEvent> mainEventList; // Rendered as a big clickable square
  List<AEvent> subEventList;  // Rendered as a little rectangle below the squares PERMANENT FOR NOW

  final Text mainText;
  final Text subText;

  final bool futureSubOnly;


  SquareDayView({Key key, this.minimumDateTime, this.maximumDateTime, this.sortingMode = SortingMode.DECREASING, this.weekDistinction = true, this.mainEventList, this.subEventList, this.mainText, this.subText, this.futureSubOnly = true}) : super(key: key) {
    minimumDateTime ??= DateTime.now().subtract(Duration(days: 7));
    maximumDateTime ??= DateTime.now().add(Duration(days: 7*4));

    minimumDateTime = extractDate(minimumDateTime);
    maximumDateTime = extractDate(maximumDateTime);

    // Dealing with null parameters
    mainEventList ??= new List<AEvent>();
    subEventList ??= new List<AEvent>();
  }

  @override
  _SquareDayViewState createState() => _SquareDayViewState();
}

class _SquareDayViewState extends State<SquareDayView> {
  DateTime today;

  Map<DateTime, List<AEvent>> _mainEventMap     = new Map<DateTime, List<AEvent>>(); // Map of the events with DateTime from which we only kept the date and not the time.
  Map<DateTime, List<AEvent>> _subEventMap      = new Map<DateTime, List<AEvent>>(); // Same for the sub events

  List<DateTime> dates = new List<DateTime>(); // List of rendered dates

  @override
  void initState() {
    super.initState();

    refresh();
  }

  void refresh() {
    today = extractDate(DateTime.now());

    // Storing the relevant dates (between the minimum and maximum ones).
    // TODO : Don't compute this at each builds... A callback for updates from the API ?

    _mainEventMap.clear();
    _subEventMap.clear();
    dates.clear(); // Stores the relevant dates to render

    // Dealing with main events
    for(AEvent event in widget.mainEventList) {
      if(event.dateTimeBegin.isBefore(widget.minimumDateTime) || event.dateTimeEnd.isAfter(widget.maximumDateTime))
        continue;

      DateTime extractedDate = extractDate(event.dateTimeBegin);
      if(!dates.contains(extractedDate)) dates.add(extractedDate); // Adding the date

      if(!_mainEventMap.containsKey(extractedDate)) _mainEventMap.addAll({extractedDate: new List<AEvent>()});
      _mainEventMap[extractedDate].add(event);
    }

    // Dealing with sub events
    for(AEvent event in widget.subEventList) {
      // We check the interval of date only if the event isn't a permanent
      if(event.dateTimeBegin.isBefore(widget.futureSubOnly ? extractDate(DateTime.now()) : widget.minimumDateTime) || event.dateTimeEnd.isAfter(widget.maximumDateTime))
        continue;

      DateTime extractedDate = extractDate(event.dateTimeBegin);
      if(!dates.contains(extractedDate)) dates.add(extractedDate); // Adding the date

      if(!_subEventMap.containsKey(extractedDate)) _subEventMap.addAll({extractedDate: new List<AEvent>()});
      _subEventMap[extractedDate].add(event);
    }


    /* Showing today even if there is no event */
    if(!dates.contains(today)) dates.add(today);

    dates.sort((a, b) => (widget.sortingMode == SortingMode.INCREASING) ? a.compareTo(b) : b.compareTo(a)); // Sorting by date
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 65, left: 10, right: 10),

      child: RefreshIndicator(
        onRefresh: () async {
          gAPI.update(APIFlags.EVENTS | APIFlags.CLUBS | APIFlags.EVENTS_SELF_GOING, onUpdateDone: () {
            this.setState(() {
              refresh();
            });
          });
        },
        child: ListView.builder( // Vertical event list view
          padding: EdgeInsets.only(top: 5, bottom: 40),
          itemCount: dates.length,
          itemBuilder: (BuildContext context, int dateIndex) {

            return Container(

              /* Date already passed filter */
              foregroundDecoration: widget.weekDistinction && dates[dateIndex].compareTo(today) < 0 ? BoxDecoration(
                color: Colors.grey[200],
                backgroundBlendMode: BlendMode.saturation,
              ) : null,

              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(width: 2, color: Colors.grey[200])),
              ),
              padding: EdgeInsets.only(bottom: 10),


              child: Column(
                children: <Widget>[
                  Row( // Calendar icon + day text row
                    children: <Widget>[
                      // Calendar icon
                      Container(
                        child: (dates[dateIndex] == today) ? Icon(
                          Icons.event_available,
                          color: Colors.red,
                          size: 27
                        ) : Icon(
                          Icons.calendar_today,
                          color: isThisWeek(dates[dateIndex]) ? Colors.red.withOpacity(0.7) : kPrimaryColor,
                        ),
                        padding: EdgeInsets.all(5),
                      ),

                      // Day text container
                      Container(
                          width: deviceSize(context).width * 0.3333, // 1/3 of the width
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(
                              top: 5,
                              right: 5,
                              left: 0,
                              bottom: 5
                          ),
                          child:  Text(
                          (dates[dateIndex] == today) ? "Today" : DateFormat("EEEE").format(dates[dateIndex]),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                color: (dates[dateIndex] == today) ? Colors.red : (isThisWeek(dates[dateIndex]) ? Colors.red.withOpacity(0.7) : kPrimaryColor),
                                fontStyle: FontStyle.italic,
                                fontSize: 13
                            ),

                            textScaleFactor: 2,
                          )
                      ),

                      Expanded(
                        child: Text(
                          DateFormat("dd/MM").format(dates[dateIndex]),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic
                          ),

                          textScaleFactor: 1.5,
                        ),
                      )

                    ],
                  ),

                  Column(
                    children: [

                      (!_mainEventMap.containsKey(dates[dateIndex]) && !_subEventMap.containsKey(dates[dateIndex]))
                      ? const Text(
                        "Nothing to do !",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                        ),
                      ) : Container(),

                      /* Main event list */
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: _mainEventMap.containsKey(dates[dateIndex]) ? widget.mainText : Container(),
                            ),
                          ),

                          Expanded(
                            child: _ListDayView(
                              eventList: _mainEventMap[dates[dateIndex]],
                              renderMode: _ListDayViewRenderMode.RENDER_MAIN,
                            ),
                          ),
                        ],
                      ),

                      /* Sub event list */
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 5),
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: _subEventMap.containsKey(dates[dateIndex]) ? widget.subText : Container(),
                            ),
                          ),

                          Expanded(
                            child: _ListDayView(
                              eventList: _subEventMap[dates[dateIndex]],
                              renderMode: _ListDayViewRenderMode.RENDER_SUB,
                            ),
                          ),
                        ],
                      )
                    ],
                  )
                  // Actual grid of event for the date pointed buu the item builder index
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Different rendering modes for the ListDayView
enum _ListDayViewRenderMode {
  RENDER_MAIN,
  RENDER_SUB,
}

/// Represents a list of main and sub events for a given, fixed, day.
class _ListDayView extends StatelessWidget {
  final List<AEvent> eventList;
  final _ListDayViewRenderMode renderMode;

  const _ListDayView({Key key, this.eventList, this.renderMode = _ListDayViewRenderMode.RENDER_MAIN}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Computing square size depending on the context so that there is always two squares on one screen, and the third visible so that the user understands that he has to scroll to see the rest.
    double _squareSize = deviceSize(context).width * 0.40;

    if(eventList == null) return Container(); // An empty container if there is nothing to render

    return Container(
      height: (renderMode == _ListDayViewRenderMode.RENDER_MAIN) ? _squareSize : 60, // 1/3 for the sub events
      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        separatorBuilder: (BuildContext context, int index) => SizedBox(width: 10),

        itemCount: eventList.length,
        itemBuilder: (BuildContext context, int index) {
          return (renderMode == _ListDayViewRenderMode.RENDER_MAIN) ? _MainItem(event: eventList[index]) : _SubItem(event: eventList[index]);
        },
      ),
    );
  }
  
}

class _MainItem extends StatelessWidget {
  final AEvent event;

  const _MainItem({Key key, this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _squareSize = deviceSize(context).width * 0.40;

    return GestureDetector(
      // For now, details are only for the main events
        onTap: () {
          Navigator.push(context, FadePageRoute(
              page: DetailsScreen(
                event: event,
              )
          ));
        },

        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(bottom: 5),
            width: _squareSize,

            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Opacity(
                    opacity: 0.8,
                    child: Hero(
                        tag: 'event: ${event.id}',
                        child: Container( // Proper event background
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: kPrimaryColor,
                              width: 4,
                              style: BorderStyle.solid,
                            ),

                            borderRadius: BorderRadius.all(Radius.circular(10.0)),

                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: event.image,
                            ),
                          ),
                        )
                    )
                ),

                /* Hovering text */
                Hero(
                  tag: 'eventText: ${event.id}',
                  child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView( // Permits to avoid text overflowing from the square just before AutoSizeText resized it.
                        scrollDirection: Axis.vertical, // Don't change it to horizontal : otherwise the text keeps begin scrollable
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            AutoSizeText(
                                '${event.title}',
                                maxLines: 1,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 30,
                                  backgroundColor: Colors.white.withOpacity(0.5),
                                )
                            ),

                            AutoSizeText(
                                event.timesToString(),
                                maxLines: 1,
                                style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20,
                                  backgroundColor: const Color(0x66FFFFFF),
                                )
                            )
                          ],
                        ),
                      )

                  ),
                )
              ],
            )
        )
    );
  }

}

// ignore: must_be_immutable
class _SubItem extends StatefulWidget {
  final AEvent event;

  _SubItem({Key key, this.event}) : super(key: key);

  @override
  _SubItemState createState() => _SubItemState();
}

class _SubItemState extends State<_SubItem> with SingleTickerProviderStateMixin {
  bool _pending = false;

  final double _maxAnimationRadius = 100;

  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = new AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animationController.addStatusListener((status) {
      if(status == AnimationStatus.forward || status == AnimationStatus.reverse) this.setState(() {});
      if(status == AnimationStatus.completed) {
        _animationController.reset();
      }
    });

    _animation = Tween<double>(begin: 0.0, end: _maxAnimationRadius).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // For now, details are only for the main events
        onTap: () {
          if(_pending) return;
          _animationController.forward();

          this.setState(() {
            widget.event.selfClientIsGoing = !widget.event.selfClientIsGoing;
            _pending = true;
          });

          /* ####################################### */
          /* #### HERE CLUB EVENTS GOING ACTION #### */
          /* ####################################### */

          widget.event.setGoing(
            gAPI.selfClient,
            going: widget.event.selfClientIsGoing,
            onConfirmed: (bool success) {
              this.setState(() {
                _pending = false;
                if(!success) {
                  widget.event.selfClientIsGoing = !widget.event.selfClientIsGoing;
                  return;
                }

                // Success from here

                if(!widget.event.selfClientIsGoing) return;

                /* Notifying the user of the action */
                Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  duration: Duration(milliseconds: 1000),
                  content: Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),

                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),

                    child: Text("You're going to " + widget.event.title + " !", textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ));

              });
            }
          );
        },

        child: AnimatedBuilder(
          animation: _animationController,
          builder: (BuildContext context, _) => Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(bottom: 5),
              width: deviceSize(context).width * 0.40,

              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  /* Pending indicator */
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: _pending ? Container(
                      margin: EdgeInsets.all(6),
                      child: SizedBox(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          strokeWidth: 2,
                        ),

                        height: 15,
                        width: 15,
                      ),
                    ) : Container(),
                  ),

                  /* Background indicator */
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(double.infinity),
                    )  ,

                    child: Icon(Icons.directions_walk, color: Colors.black, size: 35,),
                  ),

                  Opacity(
                      opacity: 0.8,
                      child: Container( // Proper event background
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: kPrimaryColor,
                            width: 2,
                            style: BorderStyle.solid,
                          ),

                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: _animationController.status == AnimationStatus.forward ? !widget.event.selfClientIsGoing ? Colors.green : Colors.deepOrange : widget.event.selfClientIsGoing ? Colors.green : Colors.deepOrange
                        ),

                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(7.0)),
                          child: CustomPaint(
                            size: Size(double.infinity, double.infinity),
                            painter: CircleWavePainter(_animation.value, widget.event.selfClientIsGoing ? Colors.green : Colors.deepOrange),
                          ),
                        )
                      )
                  ),

                  /* Hovering text */
                  Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView( // Permits to avoid text overflowing from the square just before AutoSizeText resized it.
                        scrollDirection: Axis.vertical, // Don't change it to horizontal : otherwise the text keeps begin scrollable
                        physics: NeverScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            AutoSizeText(
                                '${widget.event.title}',
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 8,
                                )
                            ),

                            Divider(
                              height: 5,
                              indent: 10,
                              endIndent: 10,
                            ),

                            AutoSizeText(
                              widget.event.location,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 5,
                              )
                            ),

                            AutoSizeText(
                                widget.event.timesToString(),
                                maxLines: 1,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 5,
                                )
                            ),
                          ],
                        ),
                      )

                  )
                ],
              )
          ),
        )
    );
  }
}

class CircleWavePainter extends CustomPainter {
  final double waveRadius;
  final Color color;
  var wavePaint;
  CircleWavePainter(this.waveRadius, this.color) {
    wavePaint = Paint()
      ..color = this.color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
  }
  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2.0;
    double centerY = size.height / 2.0;

    var currentRadius = waveRadius;

    canvas.drawCircle(Offset(centerX, centerY), currentRadius, wavePaint, );
  }

  @override
  bool shouldRepaint(CircleWavePainter oldDelegate) => false;
}