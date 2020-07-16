import 'package:barbart/constants.dart';
import 'package:barbart/pages/home/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../components/mainbody.dart';

class MainScreen extends StatelessWidget {
  MainScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //backgroundColor: kPrimaryColor,
        //appBar: _buildAppBar(),
        body: MainBody(),
      ),
    );
  }

}

AppBar _buildAppBar() {
  return AppBar(
    elevation: 0,
    title: const Text('Barb\'Art'),
    actions: <Widget>[
      IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () { // TODO : Handle the onPressed of the settings icon

          }),
    ],
  );
}