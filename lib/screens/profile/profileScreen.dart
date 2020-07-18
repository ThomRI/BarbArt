import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../multiSelectDialog.dart';

GlobalKey<ProfileScreenState> profileScreenKey = GlobalKey<ProfileScreenState>();


class ProfileScreen extends StatefulWidget {

  ProfileScreen() : super(key: profileScreenKey);

  @override
  State<StatefulWidget> createState() => ProfileScreenState();

}

class ProfileScreenState extends State<ProfileScreen>{


  @override
  Widget build(BuildContext context) {


    List <MultiSelectDialogItem<int>> multiItem = List();

    final valuesToPopulate = {
      1 : "Cuisine",
      2 : "Cinéma",
      3 : "Photo",
    };


    var selectedClubs = new List<String>();
    var _initialValuesString = new List<String>();
    var _initialValuesInt = new List<int>();

    void getInitialValues() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getStringList('initialValues')!= null){
        _initialValuesString = prefs.getStringList('initialValues');
      }
      else {
        prefs.setStringList('initialValues', new List<String>());
      }

      for(String x in _initialValuesString.toList()){
        _initialValuesInt.add(int.parse(x));
        selectedClubs.add(valuesToPopulate[x]);
      }
    }

    void populateMultiSelect(){
      for(int v in valuesToPopulate.keys){
        multiItem.add(MultiSelectDialogItem(v, valuesToPopulate[v]));
      }
    }

    void _showMultiSelect(BuildContext context) async {
      multiItem = [];
      getInitialValues();
      populateMultiSelect();
      final items = multiItem;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final selectedValues = await showDialog<Set<int>>(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialog(
            items: items,
            initialSelectedValues: _initialValuesInt.toSet(),
          );
        },
      );

      setState((){

        var _selectedValuesString = List<String>();
        final _selectedValuesInt = selectedValues.toList();
        for(int x in _selectedValuesInt){
          _selectedValuesString.add(x.toString());
        }
        prefs.setStringList('initialValues', _selectedValuesString);

      });}

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Profil'),),
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 75, bottom: 30, right: 10),
            child: RaisedButton(

              color: kPrimaryColor,
              child: Text("Clubs à afficher par défaut" ,
                style: TextStyle(color: Colors.white,),),
              onPressed: () => _showMultiSelect(context),
            ),
          ),
        ),
      ),);
  }

}