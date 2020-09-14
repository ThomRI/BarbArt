import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

// ignore: must_be_immutable
class StylizedTextField extends StatelessWidget{
  final String hint;
  final bool obscure;
  final double width;
  final double height;

  final TextEditingController fieldController;

  StylizedTextField({Key key, this.hint = "", this.obscure = false, this.width, this.height, this.fieldController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(8.0),
          width: this.width,
          height: this.height,

          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.1),
                  blurRadius: 20.0,
                  offset: Offset(0, 10),
                )
              ]
          ),

          child: TextField(
            controller: fieldController,

            obscureText: obscure,

            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
          )
        ),
      ],
    );
  }

}