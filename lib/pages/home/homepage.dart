import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:barbart/components/ControlledCarousel.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/pages/data.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barbart/components/pagelistheader.dart';
import 'package:flutter_tags/flutter_tags.dart';

class HomePage extends StatefulWidget implements AbstractPageComponent{


  HomePage({Key key}) : super(key: key);

  @override
  String get name => "Accueil";

  @override
  Icon get icon => Icon(Icons.home, color: Colors.white);

  @override
  Image get logo => Image(image: AssetImage("assets/logo_clipped.png"));

  @override
  State<StatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage>{

  bool admin;

  @override
  void initState() {
    admin=false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AbstractPageComponent.backgroundColor,
        body: Stack(
          children: <Widget>[
            ListView.builder(
                padding: EdgeInsets.only(bottom: 250),
                itemCount: 10,
                itemBuilder: (BuildContext context, int index){
                  return HomeListViewItem(liked: false, commented: false, id: index)
                  ;}
            ),
            /*Positioned(
              bottom: 280,
              right: 30,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: IconButton(
                  color: admin ? Colors.blue : Colors.grey[400],
                  icon: Icon(Icons.settings),
                  onPressed: (){setState(() {
                    admin = !admin;
                  });},
                ),
              ),
            ),*/
          ],
        )
    );
  }

}

class HomeListViewItem extends StatefulWidget{

  final bool liked;
  final bool commented;
  final int id;

  const HomeListViewItem({Key key, this.liked = false, this.commented = false, this.id}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _HomeListViewItemState();

}

class _HomeListViewItemState extends State<HomeListViewItem> with SingleTickerProviderStateMixin{

  bool _liked;
  bool _commented;
  bool _admin;
  bool _editingMainText, _editingTags;
  String _tags, _mainText;

  TextEditingController _tagController;
  TextEditingController _mainTextController;

  AnimationController _controller;
  Animation<Color> _colorAnimationLikes;
  Animation<double> _sizeAnimationLikes;

  double _minSizeIcon = 20;
  double _maxSizeIcon = 30;

  static const String Delete = "Delete";
  static const String Tags = "Change tags";
  static const String MainText = "Change text";

  List<String> adminActions = [
    Delete, Tags, MainText
  ];

  @override
  void initState() {
    _liked = widget.liked;
    _commented = widget.commented;
    _admin = false;

    _tags = '[WEI][SOIREE FOLLE]';
    _mainText = lorem;
    _editingTags = false;
    _editingMainText = false;

    _tagController = TextEditingController(text: _tags);
    _mainTextController = TextEditingController(text: _mainText);

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
  void dispose() {
    _controller.dispose();
    _tagController.dispose();
    _mainTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(_admin);
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
                  ! _admin ? Container() : PopupMenuButton(
                    icon: Icon(Icons.more_horiz), //TODO: Implements onPressed or delete the widget
                    itemBuilder: (BuildContext context){
                      return adminActions.map((String actionStr) {
                        return PopupMenuItem<String>(
                          value: actionStr,
                          child: Text(actionStr)
                        );
                      }).toList();
                    },
                    onSelected: (str) async{
                      if (str == Delete){
                        print("delete item number ${widget.id}"); // TODO: Implements function to delete this post
                      }
                      else if (str == Tags) {
                        print("tags item number ${widget.id}"); // TODO: Implements function to change post in server
                        setState(() {
                          _editingTags = true;
                        });
                      }
                      else if (str == MainText){
                        print("text item number ${widget.id}");
                        setState(() {
                          _editingMainText = true;
                        });
                      }
                    },
                  )
                ],
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: TagsWidget(admin: _admin, items: [
                  Item(title: "WEI"),
                  Item(title: "SOIREE FOLLE")],)
                /*
                ######### old version ################
                child: !_editingTags ? Text(_tags, style: TextStyle(fontSize: 17)) :
                Column(
                  children: <Widget>[
                    TextField(
                      controller: _tagController,
                      minLines: 1,
                      maxLines: 100,
                      textAlign: TextAlign.justify,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: (){
                            setState(() {
                              _tagController.clear();
                              _tagController = TextEditingController(text: _tags);
                              _editingTags = false;
                            });
                          },
                          padding: EdgeInsets.all(5),
                        ),
                        IconButton(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          onPressed: (){
                            setState(() {
                              // TODO: change text in server
                              _tags = _tagController.value.text;
                              _tagController.clear();
                              _tagController = TextEditingController(text: _tags);
                              _editingTags = false;
                            });
                          },
                          padding: EdgeInsets.all(5),
                        )
                      ],
                    )
                  ],
                ),// TEXT),// tags*/
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: !_editingMainText ? Text(_mainText) :
                Column(
                  children: <Widget>[
                    TextField(
                      controller: _mainTextController,
                      minLines: 1,
                      maxLines: 100,
                      textAlign: TextAlign.justify,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: (){
                            setState(() {
                              _mainTextController.clear();
                              _mainTextController = TextEditingController(text: _mainText);
                              _editingMainText = false;
                            });
                          },
                          padding: EdgeInsets.all(5),
                        ),
                        IconButton(
                          icon: Icon(Icons.check_circle, color: Colors.green),
                          onPressed: (){
                            setState(() {
                              // TODO: change text in server
                              _mainText = _mainTextController.value.text;
                              _mainTextController.clear();
                              _mainTextController = TextEditingController(text: _mainText);
                              _editingMainText = false;
                            });
                          },
                          padding: EdgeInsets.all(5),
                        )
                      ],
                    )
                  ],
                ),// TEXT
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
                  itemBuilder: (BuildContext context, int index){
                    return GestureDetector(
                      onLongPress: () async{
                        if (_admin){
                          await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                            title: Text('Delete this item ?'),
                            actions: <Widget>[
                              FlatButton(
                                child: Text("No"),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              FlatButton(
                                child: Text("Yes"),
                                onPressed: () {
                                  setState(() {
                                    print("The item $index has been deleted"); // TODO : Change value in server
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ));
                        }
                      },
                      child: Padding(
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

class TagsWidget extends StatefulWidget{

  final admin;
  final List items;

  const TagsWidget({Key key, this.items, this.admin}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TagsWidgetState();

}

class _TagsWidgetState extends State<TagsWidget>{

  List _items;
  final double _fontSize = 14;

  @override
  void initState(){
    super.initState();
    _items = widget.items;
    /* if you store data on a local database (sqflite), then you could do something like this
    Model().getItems().then((items){
      _items = items;
    });*/
  }

  // Allows you to get a list of all the ItemTags
  _getAllItem(){
    List<Item> lst = _tagStateKey.currentState?.getAllItem;
    if(lst!=null)
      lst.where((a) => a.active==true).forEach( ( a) => print(a.title));
  }

  final GlobalKey<TagsState> _tagStateKey = GlobalKey<TagsState>();

  @override
  Widget build(BuildContext context) {
    return Tags(
      key:_tagStateKey,
      textField: widget.admin ? TagsTextField(
        textStyle: TextStyle(fontSize: _fontSize),
        onSubmitted: (String str) {
          // Add item to the data source.
          setState(() {
            // required
            _items.add(Item(title: str));
          });
        },
      ): null,
      itemCount: _items.length, // required
      itemBuilder: (int index){
        final item = _items[index];

        return ItemTags(
          // Each ItemTags must contain a Key. Keys allow Flutter to
          // uniquely identify widgets.
          key: Key(index.toString()),
          index: index, // required
          title: item.title,
          color: kPrimaryColor,
          textColor: Colors.white,
          active: false,
          pressEnabled: false,
          customData: item.customData,
          textStyle: TextStyle( fontSize: _fontSize, ),
          combine: ItemTagsCombine.withTextBefore,// OR null,
          removeButton: widget.admin ? ItemTagsRemoveButton(
            onRemoved: (){
              // Remove the item from the data source.
              setState(() {
                // required
                _items.removeAt(index);
              });
              //required
              return true;
            },
          ) : null, // OR null,
          /*
          onPressed: (item) => print(item),
          onLongPressed: (item) => print(item),*/
        );

      },
    );
  }
}