import 'package:barbart/components/AbstractPageComponent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barbart/pages/clubs/gridViewClubs.dart';
import 'package:barbart/pages/data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../multiSelectDialog.dart';
import '../../screens/profile/profileScreen.dart';

import '../../constants.dart';

class ClubsPage extends StatefulWidget implements AbstractPageComponent{

  @override
  Icon get icon => Icon(Icons.games, color: Colors.white);

  @override
  Icon get logo => Icon(Icons.games, color: Colors.white, size: 100);

  @override
  String get name => "Clubs";

  @override

  State<StatefulWidget> createState() => _ClubPageState();


}

class _ClubPageState extends State<ClubsPage> {

  var _clubNameEvent = <String>[];
  var _clubName = <String>[];
  var _clubDate = <String>[];
  var _clubTime = <String>[];
  var _clubLocation = <String>[];
  var _clubSeatsTotal = <String>[];
  var _clubSeatsLeft = <String>[];
  var _clubImage = <String>[];
  var _clubDescription = <String>[];
  var _initialValuesString;
  var initialSelectedClubsList;
  var firstTime = true;

  final valuesInPrefs = {
    1 : "Cuisine",
    2 : "Cinéma",
    3 : "Photo",
  };

  var valuesToPopulate = {
    "Cuisine" : false,
    "Cinéma" : false,
    "Photo" : false,
  };

  void getInitialValues() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('initialValues')!= null){
      _initialValuesString = prefs.getStringList('initialValues');
    }
    else {
      prefs.setStringList('initialValues', new List<String>());
    }
    for(String x in _initialValuesString.toList()){
      valuesToPopulate[valuesInPrefs[int.parse(x)]]= true;
    }
  }

  void populateClubLists(List<String> selectedClubsList){
    _clubNameEvent = <String>[];
    _clubName = <String>[];
    _clubDate = <String>[];
    _clubTime = <String>[];
    _clubLocation = <String>[];
    _clubSeatsTotal = <String>[];
    _clubSeatsLeft = <String>[];
    _clubImage = <String>[];
    _clubDescription = <String>[];
    for (int clubId = 1; clubId < clubs.length + 1; clubId++) {
      Map<String, String> dictClub = clubs[clubId];
      if(selectedClubsList.contains(dictClub['club'])){
        _clubNameEvent.add(dictClub['name']);
        _clubName.add(dictClub['club']);
        _clubDate.add(dictClub['date']);
        _clubTime.add(dictClub['time']);
        _clubLocation.add(dictClub['location']);
        _clubSeatsTotal.add(dictClub['numberOfSeatsTotal']);
        _clubSeatsLeft.add(dictClub['numberOfSeatsLeft']);
        _clubImage.add(dictClub['image']);
        _clubDescription.add(dictClub['description']);
      }
    }
  }

  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    if (firstTime){
      getInitialValues();
      firstTime = false;
    }

    List<Widget> childrenDrawer = new List<Widget>();
    List<String> selectedClubsList = new List<String>();
    for (int index = 0; index < valuesToPopulate.length; index++){
      if (valuesToPopulate[valuesToPopulate.keys.toList()[index]]){
        selectedClubsList.add(valuesToPopulate.keys.toList()[index]);
      }

      childrenDrawer.add(
          Container(
            child: FlatButton(
              child: Column(
                children: <Widget>[
                  ColorFiltered(
                  colorFilter: ColorFilter.mode((valuesToPopulate[valuesToPopulate.keys.toList()[index]]) ? Colors.transparent : Colors.black, BlendMode.color),
                  child: Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.contain,
                        image: AssetImage('assets/images/event2.png'),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    //padding: EdgeInsets.only(left: 10),
                    child:Text(valuesToPopulate.keys.toList()[index], style: TextStyle(fontSize: 10, color: Colors.grey),)
                  ),
                ],
              ),
              onPressed: () {setState(() {
                valuesToPopulate[valuesToPopulate.keys.toList()[index]] = !valuesToPopulate[valuesToPopulate.keys.toList()[index]];
              });},
            ),
          )

      );
    }

    populateClubLists(selectedClubsList);

    return Scaffold(
      key: _scaffoldKey,
      //backgroundColor: AbstractPageComponent.backgroundColor,
      endDrawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top:65, bottom: 10),
              //color: Colors.blue,
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text("Clubs", style: TextStyle(fontSize: 30),),
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black, width: 3, style: BorderStyle.solid)),
              ),
            ),
            Container(
              //color: Colors.red,
              height: 500,
              margin: EdgeInsets.all(10),
              child: GridView.count(
              primary: false,
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.7,
              //padding: EdgeInsets.only(top: 50),
              children: childrenDrawer,
              scrollDirection: Axis.vertical,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 70, bottom: 30),
            child: Container(
              child: GridViewClubs(
                clubNameEvent: _clubNameEvent,
                clubName: _clubName,
                clubDate: _clubDate,
                clubTime: _clubTime,
                clubLocation: _clubLocation,
                clubSeatsTotal: _clubSeatsTotal,
                clubSeatsLeft: _clubSeatsLeft,
                clubImage: _clubImage,
                clubDescription: _clubDescription,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(top: 75, bottom: 30, right: 10),
            child: IconButton(
              color: kPrimaryColor,
              icon: Icon(Icons.apps),
              onPressed: (){
                _scaffoldKey.currentState.openEndDrawer();},
            ),
          ),
        ],
      ),
    );
  }
}

