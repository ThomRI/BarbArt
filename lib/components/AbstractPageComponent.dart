import 'dart:async';

import 'package:barbart/components/updatenotifier.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
abstract class AbstractPageComponent extends StatefulWidget {
  AbstractPageComponent({Key key}) : super(key: key);

  String get name;
  Icon get icon;
  dynamic get logo;

  // Update notifier
  UpdateNotifier notifier = new UpdateNotifier();
}