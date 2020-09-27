import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextIcon extends StatelessWidget {
  final Text text;
  final Icon icon;

  final Function onPressed;

  final EdgeInsets padding;
  final double height;
  final double width;
  final BoxDecoration decoration;

  const TextIcon({Key key, this.text, this.icon, this.onPressed, this.padding, this.decoration, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: this.padding,
        height: this.height,
        width: this.width,
        //color: Colors.red,
        decoration: this.decoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: this.icon,
              margin: EdgeInsets.only(right: 5),
            ),

            this.text,
          ],
        ),
      ),

      onTap: () {
        if(this.onPressed != null) {


          this.onPressed();
        } // TODO: Optimize
      }
    );
  }

}