import 'dart:async';

import 'package:barbart/components/mainbody.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../main.dart';
import '../serversplashscreen.dart';

class _LoginScreenConstants {
  static final EmailHint = "Email address";
  static final PasswordHint = "Password";

  static final LoginButtonText = "Login";
  static final SignupButtonText = "Signup";
}

class LoginScreen extends StatefulWidget {
  final String autoAuthEmail, autoAuthPassword;

  const LoginScreen({Key key, this.autoAuthEmail = "", this.autoAuthPassword = ""}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final RoundedLoadingButtonController _loginButtonController = new RoundedLoadingButtonController();
  final TextEditingController _emailFieldController = new TextEditingController();
  final TextEditingController _passwordFieldController = new TextEditingController();

  bool _authFailedState = false;

  @override
  void initState() {
    super.initState();

    // TODO: Test here if credentials are cached in a file to skip this page (auto auth)

    // For now, just use the credentials passed as the widget constructor's parameters.
    _emailFieldController.text = widget.autoAuthEmail;
    _passwordFieldController.text = widget.autoAuthPassword;
  }

  @override
  Widget build(BuildContext context) {
    /* Main Column (fields + login button) */
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            /* Avatar */
            Image.asset(
              "assets/avatar_unknown.png",
              fit: BoxFit.cover,
              width: 200.0,
            ),

            /* Fields container */
            Container(
              margin: EdgeInsets.only(
                right: 30.0,
                left: 30.0,
                bottom: 70.0,
                top: 30.0,
              ),

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

              child: Column(
                children: <Widget>[

                  /* Email field */
                  Container(
                    padding: EdgeInsets.all(8.0),

                    /* Border between the two fields */
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[100])
                      )
                    ),

                    child: TextField(
                      controller: _emailFieldController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _LoginScreenConstants.EmailHint,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  ),

                  /* Password field */
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _passwordFieldController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: _LoginScreenConstants.PasswordHint,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                      obscureText: true, // Password hidden
                    )
                  )
                ],
              ),
            ),

            /* Eventual auth failed message */
            Container(
              margin: _authFailedState ? EdgeInsets.symmetric(vertical: 10.0) : null,
              child: Text(
                _authFailedState ? "Authentication failed" : "",
                style: TextStyle(color: _authFailedState ? Colors.red: kPrimaryColor),
              )
            ),

            /* Login & Signup buttons */
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: RoundedLoadingButton(
                    controller: _loginButtonController,
                    child: Text(_LoginScreenConstants.LoginButtonText, style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      if(_authFailedState) this.setState(() {_authFailedState = false;}); // If we were in auth failed state, toggle it back.

                      /* ############################### */
                      /* ###### HERE LOGIN ACTION ###### */
                      /* ############################### */

                      print("Trying to authenticate...");
                      gAPI.authenticate(
                        email: _emailFieldController.text,
                        password: _passwordFieldController.text,

                        onAuthenticated: () {
                          print("Authenticated, uuid: " + gAPI.selfClient.uuid.toString());

                          // Launching the server splash screen that will update everything
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ServerSplashScreen(
                            nextPageNamedRoute: '/MainBody', // Loading the Main Body when splash screen loading is done.
                          )));
                        },

                        onAuthenticationFailed: () {
                          this.setState(() {
                            // Animating the login button
                            _loginButtonController.error();
                            Timer(Duration(seconds: 1), () {
                              _loginButtonController.reset();
                            });

                            // Setting the state as authentication failed state
                            _authFailedState = true;
                          });
                        }
                      );
                    },
                    color: kPrimaryColor,
                  ),
                ),

                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: const Text(
                    "OR",
                    style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                  )
                ),

                /* Sign up button */
                Container(
                  child: _Button(
                    text: "Signup",
                    onTap: () {
                      Navigator.of(context).pushNamed('/signup');
                    },
                  ),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color backgroundColor;

  bool _pressed = false;

  _Button({Key key, this.onTap, this.text = "", this.backgroundColor = kPrimaryColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {

        if(this.onTap != null) this.onTap();
      },

      child: Container(
          margin: EdgeInsets.only(bottom: 10.0),
          width: 300,
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
              gradient: LinearGradient(
                  colors: [this.backgroundColor, this.backgroundColor.withOpacity(0.5)]
              )
          ),

          child: Center(
              child: Text(
                  this.text,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )
              )
          )
      )
    );
  }

}