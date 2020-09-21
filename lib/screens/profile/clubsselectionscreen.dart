import 'package:barbart/constants.dart';
import 'package:barbart/main.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ClubsSelectionScreen extends StatefulWidget {

  @override
  _ClubsSelectionScreenState createState() => _ClubsSelectionScreenState();
}

class _ClubsSelectionScreenState extends State<ClubsSelectionScreen> {
  var clubs ={"Cinémines":true , "Jeux": true,"Oenologie":false, "Cuisine":false, "Danse latine":true, "Danse rock":false, "Mix":false};

  @override
  Widget build(BuildContext context) {
    print(clubs);
    return Scaffold(
      //backgroundColor: kPrimaryColor,
      appBar: AppBar(
        title: const Text("Clubs selection")
      ),
      body: ListView.builder(
        itemCount:clubs.length,
        itemBuilder: (BuildContext context, int index) {
          bool added = clubs[clubs.keys.toList()[index]];
          return Container(
            margin: EdgeInsets.only(top: 10, bottom: 10, right: 15, left: 15),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: added ? kPrimaryColor : Colors.white,
              border: Border.all(width: 1, style: BorderStyle.solid, color: kPrimaryColor),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  width: deviceSize(context).width*2/5,
                  child: Text(
                    clubs.keys.toList()[index],
                    style: TextStyle(fontSize: 35, fontFamily: 'Djoker', color: added ? Colors.white : kPrimaryColor),
                  ),
                ),
                IconButton(
                  icon: added ? Icon(Icons.check_circle, color: Colors.white): Icon(Icons.add_circle, color: kPrimaryColor),
                  onPressed: (){
                    setState(() {
                      clubs[clubs.keys.toList()[index]] = !added;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: added ? Colors.white : kPrimaryColor),
                )
              ],
            )
          );
        },
      ),
    );
  }
}