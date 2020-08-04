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

  var _eventClubsDates = Map<String, List<int>>();
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

  void populateClubLists(){

    List<String> selectedClubsList = new List<String>();

    for (int index = 0; index < valuesToPopulate.length; index++){
      if (valuesToPopulate[valuesToPopulate.keys.toList()[index]]){
        selectedClubsList.add(valuesToPopulate.keys.toList()[index]);
      }
    }

    String date;
    _eventClubsDates = Map<String, List<int>>();
    for (int eventId = 1; eventId < clubs.length + 1; eventId++) {
      date = clubs[eventId]['date'];
      if(selectedClubsList.contains(clubs[eventId]['club'])){
        if (_eventClubsDates.containsKey(date)) {
          _eventClubsDates[date].add(eventId);
        } else {
          _eventClubsDates.addAll({date: [eventId]});
        }
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

    populateClubLists();

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
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.7,
                  //padding: EdgeInsets.only(top: 50),
                  ),
                itemCount: valuesToPopulate.length,
                itemBuilder: (BuildContext context, int index){
                  return Container(
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
                  );
                },
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
              child: ListViewDaysClubs(
                eventDates: _eventClubsDates,
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

