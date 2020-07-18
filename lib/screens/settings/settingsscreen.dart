import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(title: const Text('Settings'),),
      backgroundColor: Colors.white,
      body: Center(
        child: Text("Settings Page"),
      ),
    ),);
  }
  
}