import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/components/ControlledCarousel.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/pages/data.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HomePage extends StatelessWidget implements AbstractPageComponent{
  HomePage({Key key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AbstractPageComponent.backgroundColor,

      key: _scaffoldKey,
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (BuildContext context, int index){
          return HomeListViewItem(liked: false, commented: false,)
        ;}
      )
    );
  }

  @override
  String get name => "Accueil";

  @override
  Icon get icon => Icon(Icons.home, color: Colors.white);

  @override
  Image get logo => Image(image: AssetImage("assets/logo_clipped.png"));

}

class HomeListViewItem extends StatefulWidget{

  final bool liked;
  final bool commented;

  const HomeListViewItem({Key key, this.liked = false, this.commented = false}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _HomeListViewItemState();

}

class _HomeListViewItemState extends State<HomeListViewItem> with SingleTickerProviderStateMixin{

  bool _liked;
  bool _commented;

  AnimationController _controller;
  Animation<Color> _colorAnimationLikes;
  Animation<double> _sizeAnimationLikes;

  double _minSizeIcon = 20;
  double _maxSizeIcon = 30;

  @override
  void initState() {
    _liked = widget.liked;
    _commented = widget.commented;

    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );


    _colorAnimationLikes = ColorTween(begin: Colors.grey[400], end: Colors.green).animate(_controller);

    _sizeAnimationLikes = TweenSequence(
        <TweenSequenceItem<double>>[
          TweenSequenceItem<double> (tween: Tween<double>(begin: _minSizeIcon, end: _maxSizeIcon), weight: 50),
          TweenSequenceItem<double> (tween: Tween<double>(begin: _maxSizeIcon, end: _minSizeIcon), weight: 50),
        ]
    ).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        setState(() {
         _liked = true;
        });
      }
      if (status == AnimationStatus.reverse) {
        setState(() {
          _liked = false;
        });
      }
    });
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, _){
        return Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/logo.png'),
                      ),
                      SizedBox(width: 10,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text('Name Firstname', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
                          Text('5 min ago', style: TextStyle(fontSize: 15, color: Colors.grey),),
                        ],
                      )
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz), //TODO: Implements onPressed or delete the widget
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text('[WEI][SOIREE FOLLE]', style: TextStyle(fontSize: 17),),// tags
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text(lorem),// TEXT
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                decoration: _commented ? null : BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.grey[300],
                            width: 1,
                            style: BorderStyle.solid
                        )
                    )
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.thumb_up,
                            color: _colorAnimationLikes.value,
                            size: _sizeAnimationLikes.value,
                          ),
                          onPressed: (){
                            setState(() {
                              _liked ? _controller.reverse() : _controller.forward();
                            });
                          },
                        ),
                        Align(child: Text('90 likes', style: TextStyle(color: _colorAnimationLikes.value),),)
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(
                            Icons.chat_bubble,
                            color: _commented ? Colors.blue : Colors.grey[400],
                          ),
                          onPressed: (){
                            setState(() {
                              _commented = !_commented;
                            });
                          },
                        ),
                        Align(child: Text('12 comments', style: TextStyle(color: _commented ? Colors.blue : Colors.grey[400]),))
                      ],
                    )
                  ],
                ),
              ),
              (!_commented) ? Container() :
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: kPrimaryColor.withAlpha(50),
                    width: 1,
                    style: BorderStyle.solid
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                height: 400,
                child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: 10,
                  itemBuilder: (BuildContext context, _){
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/logo.png'),
                          ),
                          SizedBox(width: 10,),
                          Container(
                            width: MediaQuery.of(context).size.width - 120,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Name Firstname', style: TextStyle(color: Colors.black,fontSize: 15, fontWeight: FontWeight.bold),),
                                RichText(textAlign: TextAlign.justify,text:TextSpan(text: lorem.substring(0, 100), style: TextStyle(fontSize: 12, color: Colors.black, ),)),
                                Text('20 min ago', style: TextStyle(color: Colors.grey[400]),)
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ;}
                ),
              )
            ],
          ),
        );
      },
    );
  }

}