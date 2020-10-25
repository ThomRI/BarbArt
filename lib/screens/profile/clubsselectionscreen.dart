import 'package:barbart/api/structures.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/pages/clubdetailsscreen.dart';
import 'package:barbart/pages/events/detailsscreen.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../main.dart';

class ClubsSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ClubsSelectionScreenWarper(),
    );
  }

}

class ClubsSelectionScreenWarper extends StatefulWidget {
  @override
  _ClubsSelectionScreenWarperState createState() => _ClubsSelectionScreenWarperState();
}

class _ClubsSelectionScreenWarperState extends State<ClubsSelectionScreenWarper> with SingleTickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clubs selection"),
        bottom: TabBar(
          tabs: gAPI.getClubCategoryList.map((category) => Tab(text: category)).toList(),
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: TabBarView(
        children: gAPI.getClubCategoryList.map((category) => Container(
          color: Colors.white,
          child: ListView.builder(
              itemCount: gAPI.getClubListByCategory(category).length,
              itemExtent: 90,
              itemBuilder: (BuildContext context, int index) {
                return _ClubCard(
                    club: gAPI.getClubListByCategory(category)[index]
                );
              }
          ),
        ),).toList(),

      )
    );
  }
}

// ignore: must_be_immutable
class _ClubCard extends StatefulWidget {
  final AClub club;

  _ClubCard({this.club});

  @override
  _ClubCardState createState() => _ClubCardState();
}

class _ClubCardState extends State<_ClubCard> {
  bool enabled = true;

  @override
  Widget build(BuildContext context) {
    bool isMember = gAPI.selfClient.isClubMember(widget.club);

    return GestureDetector(
      child: Card(
          color: isMember ? kPrimaryColor : Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: kPrimaryColor,
            ),

            borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Stack(

              children: [

                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(
                      isMember ? Icons.check_circle : Icons.add_circle,
                      color: isMember ? Colors.white : kPrimaryColor,
                      size: 30,
                    ),
                  )
                ),

                /*
                VerticalDivider(
                  indent: 10,
                  endIndent: 10,
                  color: isMember ? Colors.white : kPrimaryColor,
                ),*/

                Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                        widget.club.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isMember ? Colors.white : kPrimaryColor,
                          fontSize: 35,
                          fontFamily: "Djoker",
                          fontStyle: isMember ? FontStyle.italic : null,
                        )
                    ),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward_ios, color: isMember ? Colors.white : kPrimaryColor),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ClubDetailsScreen(
                          club: widget.club,
                        )
                      ));
                    },
                  ),
                )

              ],
            ),
          )
      ),

      onTap: () {
        if(!this.enabled) return; // Spam protection

        /* ########################################### */
        /* ###### HERE CLUB REGISTRATION ACTION ###### */
        /* ########################################### */

        this.enabled = false;

        this.setState(() { // This will work as the registerClient function will first change the value when triggered. Only after is the 'await' of the request which will let the setState() continue its work.
          widget.club.registerClient(
              client: gAPI.selfClient,
              member: !gAPI.selfClient.isClubMember(widget.club), // Change status
              changeValueOnTrigger: true,

              onConfirmed: (bool success) {
                this.setState(() { // The registerClient function already has updated the membership state of the client, so just setState() and it will update accordingly.
                  this.enabled = true;
                });
              }
          );
        });
      },
    );
  }
}