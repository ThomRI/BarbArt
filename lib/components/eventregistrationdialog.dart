import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../utils.dart';
import 'messageloadingbutton.dart';

class EventRegistrationDialog {
  // Note: onConfirm returns a Future<bool> so that the validation button can change state when onConfirmed if done.
  static Future<void> show(BuildContext context, {DateTime day, Text title, Widget headerContent, Future<bool> Function(DateTime beginTime, DateTime endTime) onConfirmed}) async {
    GlobalKey<MessageLoadingButtonState> validationKey = new GlobalKey<MessageLoadingButtonState>();
    _RegistrationTimePicker timePicker = new _RegistrationTimePicker(startTime: day, endTime: day);
    
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title,
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                headerContent ?? Container(),

                /* Start & End time picker */
                timePicker,

                /* Validation button */
                MessageLoadingButton(
                  key: validationKey,
                  width: 200,
                  errorMessage: "Invalid times",
                  onPressed: () async {
                    bool success = true; // If no onConfirmed function provided, assume success.
                    if(onConfirmed != null) success = await onConfirmed(timePicker.begin, timePicker.end);

                    if(success) {
                      Timer(Duration(seconds: 1), () {
                        Navigator.of(context).pop(); // Close the AlertDialog
                      });
                    }

                    return success;
                  }
                )
              ],
            ),
          ),
        );
      }
    );
  }

}

class _RegistrationTimePicker extends StatelessWidget {
  final DateTime startTime, endTime;

  GlobalKey<_CustomTimePickerState> startKey = new GlobalKey<_CustomTimePickerState>();
  GlobalKey<_CustomTimePickerState> endKey = new GlobalKey<_CustomTimePickerState>();

  DateTime get begin  => startKey.currentState.time;
  DateTime get end    => endKey.currentState.time;

  _RegistrationTimePicker({this.startTime, this.endTime});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[

        /* Start row */
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Start at"),
            _CustomTimePicker(key: startKey, initialTime: this.startTime ?? DateTime.now())
          ],
        ),

        /* End row */
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("End at"),
            _CustomTimePicker(key: endKey, initialTime: this.endTime ?? DateTime.now()),
          ],
        )
      ],
    );
  }

}

class _CustomTimePicker extends StatefulWidget {
  final DateTime initialTime;

  const _CustomTimePicker({Key key, this.initialTime}) : super(key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<_CustomTimePicker> {
  DateTime time;

  @override
  void initState() {
    super.initState();
    time = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        child: Text(timeToString(time)),
        onPressed: () {
          DatePicker.showTimePicker(
            context,
            showTitleActions: false,
            showSecondsColumn: false,

            onChanged: (date) {
              this.setState(() {
                this.time = date.toLocal();
              });
            },

            currentTime: time,
          );
        }
    );
  }
}