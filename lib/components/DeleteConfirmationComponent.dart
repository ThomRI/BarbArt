import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'messageloadingbutton.dart';

class DeleteConfirmationComponent{
  // Note: onConfirm returns a Future<bool> so that the validation button can change state when onConfirmed if done.
  static Future<void> show(BuildContext context, {Text title, Widget headerContent, Future<bool> Function() onConfirmed}) async {

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
                  Center(
                    child: MessageLoadingButton(
                      //key: validationKey,
                        width: 200,
                        errorMessage: "Invalid times",
                        onPressed: () async {
                          Timer(Duration(seconds: 1), () {
                            Navigator.of(context).pop(); // Close the AlertDialog
                          });
                          return true;
                        }
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

}
