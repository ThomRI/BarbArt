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
  var _clubImage = <String>[];
  var _clubDescription = <String>[];
  var initialValues;
  var _selectedClubs = new List<String>();
  var _initialValuesModified = false;
  var selectedValues;

  final valuesToPopulate = {
    1 : "Cuisine",
    2 : "Cinéma",
    3 : "Photo",
  };

  void getInitialValues() async{
    var _initialValuesString = new List<String>();
    initialValues = new List<int>();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getStringList('initialValues')!= null){
      _initialValuesString = prefs.getStringList('initialValues');
    }
    else {
      prefs.setStringList('initialValues', new List<String>());
    }

    for(String x in _initialValuesString.toList()){
      initialValues.add(int.parse(x));
    }
  }

  List <MultiSelectDialogItem<int>> multiItem = List();

  void populateMultiSelect(){
    for(int v in valuesToPopulate.keys){
      multiItem.add(MultiSelectDialogItem(v, valuesToPopulate[v]));
    }
  }

  void populateClubLists(List<String> selectedClubsList){
    _clubNameEvent = <String>[];
    _clubName = <String>[];
    _clubDate = <String>[];
    _clubTime = <String>[];
    _clubImage = <String>[];
    _clubDescription = <String>[];
    for (int clubId = 1; clubId < clubs.length + 1; clubId++) {
      Map<String, String> dictClub = clubs[clubId];
      if(selectedClubsList.contains(dictClub['club'])){
        _clubNameEvent.add(dictClub['name']);
        _clubName.add(dictClub['club']);
        _clubDate.add(dictClub['date']);
        _clubTime.add(dictClub['time']);
        _clubImage.add(dictClub['image']);
        _clubDescription.add(dictClub['description']);
      }
    }
  }

  void _showMultiSelect(BuildContext context) async {
    multiItem = [];
    if (_initialValuesModified){
      initialValues = selectedValues.toList();
    } else {
      getInitialValues();
    }
    populateMultiSelect();
    final items = multiItem;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: initialValues.toSet(),
        );
      },
    );

    setState((){
      _initialValuesModified = true;
      final _selectedValuesInt = selectedValues.toList();
      _selectedClubs = new List<String>();
      for (int x in _selectedValuesInt){
        _selectedClubs.add(valuesToPopulate[x]);
      }
    });
  }

  @override
  void initState() {
    _showMultiSelect(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    populateClubLists(_selectedClubs);

    return Scaffold(
      backgroundColor: AbstractPageComponent.backgroundColor,
      body: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(top: 70, bottom: 30),
            child: Container(
              child: GridViewDays(
                clubNameEvent: _clubNameEvent,
                clubName: _clubName,
                clubDate: _clubDate,
                clubTime: _clubTime,
                clubImage: _clubImage,
                clubDescription: _clubDescription,
              ),
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(top: 75, bottom: 30, right: 10),
            child: RaisedButton(
              color: kPrimaryColor,
              child: Text("Clubs",
                  style: TextStyle(color: Colors.white,),),
              onPressed: () => _showMultiSelect(context),
            ),
          ),
        ],
      ),
    );
  }
}

