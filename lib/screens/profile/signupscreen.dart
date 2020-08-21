import 'package:barbart/api/structures.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../main.dart';
import 'loginscreen.dart';

class _SignupScreenConstants {
  static final FirstnameHint    = "Firstname";
  static final LastnameHint         = "Name";
  static final EmailHint        = "Email";
  static final PasswordHint     = "Password";

  static final SignupButtonText = "Signup";
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  /* Fields */
  _FancyTextField _firstnameField = new _FancyTextField(hintText: _SignupScreenConstants.FirstnameHint,);
  _FancyTextField _lastnameField = new _FancyTextField(hintText: _SignupScreenConstants.LastnameHint,);
  _FancyTextField _emailField = new _FancyTextField(hintText: _SignupScreenConstants.EmailHint,);
  _FancyTextField _passwordField = new _FancyTextField(hintText: _SignupScreenConstants.PasswordHint, border: false, obscureText: true,);

  final RoundedLoadingButtonController _signupButtonController = new RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /* Main colummn */
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: const Text("Signup"),
        centerTitle: true,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[

          /* Fields container */
          Container(
            margin: EdgeInsets.only(
              right: 30.0,
              left: 30.0,
              top: 30.0,
              bottom: 70.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryColor.withOpacity(0.1),
                  blurRadius: 20.0,
                  offset: Offset(0, 10.0),
                )
              ]
            ),

            child: Column(
              children: <Widget>[
                _firstnameField,
                _lastnameField,
                _emailField,
                _passwordField
              ],
            )
          ),

          /* Buttons */
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RoundedLoadingButton(
                controller: _signupButtonController,
                child: Text(_SignupScreenConstants.SignupButtonText, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  // TODO: Implement and remove following error code
                  _signupButtonController.error();
                  return;

                  /* ################################ */
                  /* ###### HERE SIGNUP ACTION ###### */
                  /* ################################ */

                  gAPI.register(
                    firstname: _firstnameField.text,
                    lastname: _lastnameField.text,
                    email: _emailField.text,
                    password: _passwordField.text,
                    makeSelf: true,

                    onRegistered: (AClient client) {
                      // On registered, get back to the login page with pre filled credentials
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen(
                        autoAuthEmail: _emailField.text,
                        autoAuthPassword: _passwordField.text,
                      )));
                    },

                    onRegistrationFailed: () {

                    },
                  );
                }
              )
            ],
          )


        ],
      ),
    );
  }
}

class _FancyTextField extends StatelessWidget {
  final String hintText;
  final bool border;
  final bool obscureText;

  final TextEditingController _controller = new TextEditingController();

  _FancyTextField({Key key, this.hintText, this.border = true, this.obscureText = false}) : super(key: key);

  String get text => _controller.text;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8.0),
        decoration: this.border ? BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]))) : null,
        child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: this.hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          obscureText: this.obscureText,
        )
    );
  }

}