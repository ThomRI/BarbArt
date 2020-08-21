import 'dart:async';

import 'package:barbart/constants.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class UpdateNotifier extends StatefulWidget {
  ValueNotifier<bool> _notify = new ValueNotifier<bool>(false);

  void notify() {
    _notify.value = true;
  }

  Future<void> done() async {
    _notify.value = false;
  }

  @override
  _UpdateNotifierState createState() => _UpdateNotifierState();
}

class _UpdateNotifierState extends State<UpdateNotifier> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: kDefaultNotifierDuration);
    _offset = new Tween<Offset>(begin: Offset(0.0, -2.0), end: Offset(0.0, 0.0)).animate(_controller);

    // Update when notify is changed
    widget._notify.addListener(() { this.setState(() {
      (widget._notify.value) ? _controller.forward() : _controller.reverse();
    });});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: Container(
        width: deviceSize(context).width,
        color: Colors.deepOrange,
        padding: EdgeInsets.all(10.0),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: const Text(
            "Update available",
            style: TextStyle(
              color: Colors.white,
            )
          ),
        ),
      ),
    );
  }
}