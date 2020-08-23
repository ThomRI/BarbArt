import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

// ignore: must_be_immutable
class ColoredButton extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color backgroundColor;
  final IconData iconData;
  final bool enableColor;
  final Alignment iconAlignment;
  final bool enabled;

  bool _pressed = false;

  ColoredButton({ Key key,
                  this.onTap,
                  this.text = "",
                  this.backgroundColor = kPrimaryColor,
                  this.iconData,
                  this.enableColor = true,
                  this.iconAlignment = Alignment.centerLeft,
                  this.enabled = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {

          if(this.onTap != null) this.onTap();
        },

        child: Container(
            margin: EdgeInsets.only(bottom: 10.0),
            width: deviceSize(context).width * kDefaultButtonWidthRatio,
            height: 50,
            decoration: BoxDecoration(
              border: this.enableColor ? null
                  : Border.all(
                  color: this.enabled ? kPrimaryColor : Colors.grey,
                  style: BorderStyle.solid,
                  width: 1
              ),
              borderRadius: BorderRadius.circular(40.0),
              gradient: this.enableColor ? LinearGradient(
                  colors: [this.backgroundColor, this.backgroundColor.withOpacity(0.5)]
              ) : null,
            ),

            child: Stack(
              children: <Widget>[
                Align(
                  alignment: this.iconAlignment,
                  child: Container(
                      padding: EdgeInsets.only(left: 15, right: 15),
                      child: Icon(this.iconData, color: this.enabled ? (this.enableColor ? Colors.white : kPrimaryColor) : Colors.grey),
                  ),
                ),

                Center(
                    child: Text(
                        this.text,
                        style: TextStyle(
                          color: this.enabled ? (this.enableColor ? Colors.white : kPrimaryColor) : Colors.grey,
                          fontWeight: FontWeight.bold,
                        )
                    )
                ),
              ],
            )
        )
    );
  }
}