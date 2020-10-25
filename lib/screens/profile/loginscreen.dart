import 'dart:async';

import 'package:barbart/api/APIManager.dart';
import 'package:barbart/components/ColoredButton.dart';
import 'package:barbart/components/mainbody.dart';
import 'package:barbart/constants.dart';
import 'package:barbart/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../main.dart';
import '../mainscreen.dart';
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

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {

  final RoundedLoadingButtonController _loginButtonController = new RoundedLoadingButtonController();
  final TextEditingController _emailFieldController = new TextEditingController();
  final TextEditingController _passwordFieldController = new TextEditingController();

  bool _authFailedState           = false;
  bool _attemptingAutoAuthState   = true;

  AnimationController _animationController;
  Animation<double> _avatarAnimation;
  Animation<double> _fieldsAnimation;

  @override
  void initState() {
    super.initState();

    /* Auto authentication test : token validity test */
    print("Attempting to auto auth...");
    _attemptingAutoAuthState = true;
    gAPI.attemptAutoLogin().then((success) {
      this.setState(() {
        _attemptingAutoAuthState = false;
      });

      if(!success) {
        print("Auto auth failed.");
        return;
      }

      // Pushing after the frame if built avoids to break the states tree.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        MainScreen.pushToApp(context);
      });
    });

    // Using API cached email if existing.
    _emailFieldController.text = gAPI.selfClient.email ?? widget.autoAuthEmail;
    _passwordFieldController.text = widget.autoAuthPassword;

    /* Animations */
    _animationController = new AnimationController(duration: Duration(milliseconds: 150), vsync: this);
    _avatarAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
    _fieldsAnimation = Tween<double>(begin: 0.0, end: 250).animate(_animationController);


    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool opened) {
        if(opened)  _animationController.forward();
        else        _animationController.reverse();
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    /* Main Column (fields + login button) */
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),

      body: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, _) => Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[


            /* Avatar */
            Opacity(
              opacity: _avatarAnimation.value,
              child: Image.asset(
                "assets/avatar_unknown.png",
                fit: BoxFit.cover,
                width: 200.0,
                height: _avatarAnimation.value * 200.0,
              ),
            ),

            Container(
              margin: EdgeInsets.only(
                right: 30.0,
                left: 30.0,
                top: 30.0,
              ),

              child: Column(
                children: [
                  /* Auto auth notification */
                  Opacity(
                    opacity: (_attemptingAutoAuthState) ? 1 : 0,
                    child: Container(
                      margin: EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                              strokeWidth: 1,
                            ),
                          ),

                          SizedBox(
                            width: 5,
                          ),

                          Text(
                            "Attempting auto login...",
                            style: TextStyle(
                              color: Colors.grey
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /* Fields container */
                  Container(
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
                            autofocus: true,
                            keyboardType: TextInputType.emailAddress,
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
                ],
              ),
            ),

            /* Eventual auth failed message */
            Container(
              margin: _authFailedState ? EdgeInsets.only(top: 5.0) : null,
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
                    width: deviceSize(context).width * kDefaultButtonWidthRatio,
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
                          MainScreen.pushToApp(context);
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
                ColoredButton(
                  text: "Signup",
                  iconData: Icons.arrow_forward,
                  iconAlignment: Alignment.centerRight,
                  enableColor: false,
                  onTap: () {
                    Navigator.of(context).pushNamed('/signup');
                  },
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}