import 'package:barbart/constants.dart';

import '../myClipper.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../data.dart';

class DetailsScreenEvent extends StatelessWidget {
  final String eventString;
  final String dayString;
  final String timeString;
  final String locationString;
  final String peopleGoing;
  final String imagePath;
  final String description;

  DetailsScreenEvent(this.eventString, this.dayString, this.timeString,
      this.locationString, this.peopleGoing, this.imagePath, this.description)
      : super();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: background_color,
      appBar: AppBar(
        title: Text(eventString),
      ),
      body: Center(
          child: ListViewDetails(eventString, dayString, timeString, locationString, peopleGoing, imagePath, description)
      ),
    );
  }
}

class ListViewDetails extends StatefulWidget{
  final String eventString;
  final String dayString;
  final String timeString;
  final String locationString;
  final String peopleGoing;
  final String imagePath;
  final String description;


  ListViewDetails(this.eventString, this.dayString, this.timeString,
      this.locationString, this.peopleGoing, this.imagePath,
      this.description) : super(key : new GlobalKey());

  @override
  State<StatefulWidget> createState() => _ListViewDetailsState();


}

class _ListViewDetailsState extends State<ListViewDetails> with SingleTickerProviderStateMixin{

  var going = false;
  AnimationController _controller;
  Animation<Color> _colorAnimation;
  Animation<double> _sizeAnimation;

  double _minSizeIcon = 20;
  double _maxSizeIcon = 30;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _colorAnimation = ColorTween(begin: Colors.grey[400], end: Colors.green).animate(_controller);

    _sizeAnimation = TweenSequence(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double> (tween: Tween<double>(begin: _minSizeIcon, end: _maxSizeIcon), weight: 50),
          TweenSequenceItem<double> (tween: Tween<double>(begin: _maxSizeIcon, end: _minSizeIcon), weight: 50),
        ]
    ).animate(_controller);


    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        setState(() {
          going = true;
        });
      }
      if (status == AnimationStatus.reverse) {
        setState(() {
          going = false;
        });
      }
    });
  }

  // dismiss the animation when widgit exits screen
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _){
        return ListView(children: <Widget>[
          Hero(
            tag: '${widget.dayString} ${widget.timeString}',
            child: ClipPath(
              clipper: MyClipper(),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red,
                  image: DecorationImage(
                    image: AssetImage(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 30, left: 30),
            child: Text(
              ' ${widget.eventString}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 30,
                backgroundColor: const Color(0x66FFFFFF),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 30, left: 30, right: 30, top: 5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.calendar_today),
                  Text(
                    ' ${widget.dayString.substring(0, 1).toUpperCase() + widget.dayString.substring(1)} : ${widget.timeString} ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      backgroundColor: const Color(0x66FFFFFF),
                    ),
                  ),
                ]
            ),
          ),


          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.place),
                      Text(' ${widget.locationString.substring(0, 1).toUpperCase()
                          + widget.locationString.substring(1)} ',style: TextStyle(
                        fontSize: 20,))
                    ]
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(child: Icon(Icons.check_circle, color: Colors.green,size: _sizeAnimation.value,), width: _maxSizeIcon, height: _maxSizeIcon),
                      Container(
                        child: Text('${int.parse(widget.peopleGoing) + ((going) ? 1 : 0)}', style: TextStyle(
                          fontSize: 20,)),
                        padding: EdgeInsets.all(5),
                      ),
                    ]
                ),
              ],
            ),
            margin: EdgeInsets.only(left: 40, right: 40),
            padding: EdgeInsets.only(top: 5, bottom: 5, ),
            decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid),
                  bottom: BorderSide(color: Colors.grey, width: 1, style: BorderStyle.solid),
                )
            ),
          ),

          Container(
            margin: EdgeInsets.only(top : 10),
            padding: EdgeInsets.only(left: 30, right: 30),
            child: GestureDetector(
              onTap:() => setState(() {
                going ? _controller.reverse() : _controller.forward();
              }),
              child: Container(
                height: _maxSizeIcon,
                alignment: Alignment.center,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.directions_walk,
                        size: _sizeAnimation.value,
                        color: _colorAnimation.value,
                      ),
                      Text(
                        '${(going) ? ' going' : ' not going'}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                            color: _colorAnimation.value,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ]
                ),
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(30),
            child: Text(
              '${widget.description}',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                //color: Colors.white,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),


          Container(
            margin: const EdgeInsets.only(top: 20),
            width: 100,
            height: 70,
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              // border: new Border.all(
              //   color: primary_color,
              //   width: 5,
              //   style: BorderStyle.solid,
              // ),
              image: const DecorationImage(
                fit: BoxFit.scaleDown,
                image: AssetImage('assets/images/logo-barbart2.png'),
              ),
            ),
          ),
        ]
        );
      }
    );
  }

}
