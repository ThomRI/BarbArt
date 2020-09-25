import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../constants.dart';
import '../utils.dart';
import 'messageloadingbutton.dart';

class EventRegistrationDialog {
  // Note: onConfirm returns a Future<bool> so that the validation button can change state when onConfirmed if done.
  static Future<void> show(BuildContext context, {DateTime day, Text title, Widget headerContent, Future<bool> Function(DateTime begin, DateTime end,) onConfirmed}) async {
    GlobalKey<MessageLoadingButtonState> validationKey = new GlobalKey<MessageLoadingButtonState>();
    _RegistrationDateTimePicker dateTimePicker = new _RegistrationDateTimePicker(startTime: day, endTime: day, initialDate: day, lastDate: day.add(Duration(days: kDaysIntervalRegistrationAllowed)));
    
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
                dateTimePicker,

                /* Validation button */
                MessageLoadingButton(
                  key: validationKey,
                  width: 200,
                  errorMessage: "Invalid times",
                  onPressed: () async {
                    bool success = true; // If no onConfirmed function provided, assume success.
                    if(onConfirmed != null) {
                      DateTime pickedDate = dateTimePicker.date;
                      DateTime pickedBeginTime = dateTimePicker.begin;
                      DateTime pickedEndTime = dateTimePicker.end;

                      DateTime begin  = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedBeginTime.hour, pickedBeginTime.minute, pickedBeginTime.second);
                      DateTime end    = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedEndTime.hour, pickedEndTime.minute, pickedEndTime.second);

                      success = await onConfirmed(begin, end);
                    }

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

// ignore: must_be_immutable
class _RegistrationDateTimePicker extends StatelessWidget {
  final DateTime startTime, endTime;
  final DateTime initialDate, lastDate;

  GlobalKey<_CustomTimePickerState> startKey = new GlobalKey<_CustomTimePickerState>();
  GlobalKey<_CustomTimePickerState> endKey = new GlobalKey<_CustomTimePickerState>();
  GlobalKey<_CustomDatePickerState> dateKey = new GlobalKey<_CustomDatePickerState>();

  DateTime get begin  => startKey.currentState.time;
  DateTime get end    => endKey.currentState.time;
  DateTime get date   => dateKey.currentState.date;

  _RegistrationDateTimePicker({this.startTime, this.endTime, this.initialDate, this.lastDate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[

        /* Date Row */
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Text("Date"),
            _CustomDatePicker(key: dateKey, firstDate: this.initialDate, lastDate: this.lastDate),
          ],
        ),

        /* Start row */
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            const Text("Start at"),
            _CustomTimePicker(key: startKey, initialTime: this.startTime ?? DateTime.now())
          ],
        ),

        /* End row */
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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

class _CustomDatePicker extends StatefulWidget {
  final DateTime  firstDate,
                  lastDate;

  const _CustomDatePicker({Key key, this.firstDate, this.lastDate}) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<_CustomDatePicker> {
  DateTime date;

  @override
  void initState() {
    super.initState();
    date = widget.firstDate;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text(DateFormat("dd/MM/yyyy").format(date)),
      onPressed: () async {
        final DateTime picked = await showDatePicker(
          context: context,
          firstDate: widget.firstDate,
          initialDate: widget.firstDate,
          lastDate: widget.lastDate,
        );

        if(picked == null) return;

        this.setState(() {
          date = picked;
        });
      },
    );
  }
}