import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class MessageLoadingButton extends StatefulWidget {
  final Future<bool> Function() onPressed; // returns true for success, false otherwise.
  final String errorMessage;

  final double width;

  const MessageLoadingButton({Key key, this.errorMessage, this.onPressed, this.width}) : super(key: key);

  @override
  MessageLoadingButtonState createState() => MessageLoadingButtonState();
}

class MessageLoadingButtonState extends State<MessageLoadingButton> {
  bool error;
  RoundedLoadingButtonController controller;

  @override
  void initState() {
    super.initState();

    controller = new RoundedLoadingButtonController();
    error = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        /* Error message */
        Text(error ? widget.errorMessage : "", style: TextStyle(color: Colors.red)),

        /* Button */
        RoundedLoadingButton(
          width: widget.width,
          controller: controller,
          child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          onPressed: () {
            this.setState(() {
              this.controller.start();

              if(widget.onPressed != null) widget.onPressed()..then((success) {
                if(!success) {
                  controller.error();
                  Timer(Duration(seconds: 1), () {
                    controller.reset();
                  });
                } else { // Assuming success
                  controller.success();
                }
              });
            });
          }
        )
      ],
    );
  }
}