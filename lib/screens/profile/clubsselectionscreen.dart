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
      appBar: AppBar(
        title: const Text("Clubs selection")
      ),
      body: ListView.builder(
        itemCount:clubs.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: deviceSize(context).height/6,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
            ),
            child: GestureDetector(
              onTap: (){
                setState(() {
                  clubs[clubs.keys.toList()[index]] = !clubs[clubs.keys.toList()[index]];
                });
              },
              child: Stack(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(clubs[clubs.keys.toList()[index]] ? Colors.lightGreen: Colors.grey, BlendMode.color),
                          image: AssetImage("assets/images/event"+(index%3+1).toString()+".png"),
                        )
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.white.withAlpha(178),
                      ),
                      child: Text(
                        clubs.keys.toList()[index],
                        style: TextStyle(fontSize: 35, fontFamily: 'Djoker'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}