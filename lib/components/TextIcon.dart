import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  final Text text;
  final Icon icon;

  const TextIcon({Key key, this.text, this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: this.icon,
          margin: EdgeInsets.only(right: 5),
        ),

        this.text,
      ],
    );
  }

}