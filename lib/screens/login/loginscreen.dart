import 'package:barbart/constants.dart';
import 'package:barbart/multiSelectDialog.dart';
import 'package:barbart/pages/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginScreenState();

}

class _LoginScreenState extends State<LoginScreen>{
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: <Widget>[
                CircleAvatar(backgroundImage: AssetImage('assets/logo.png'),),
                SizedBox(width: 20,),
                Text('Barb\'art', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),)
              ],
            ),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.check), text: "Log in",),
                Tab(icon: Icon(Icons.person), text: "Sign up",),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              LoginTab(),
              SignUpTab(),
            ],
          )
        ),
      )
    );
  }

}


class LoginTab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LoginTabState();

}

class _LoginTabState extends State<LoginTab>{

  bool _validMail = false;
  bool _validPassword = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool testValidityMail(String str){
    return (str.length == 3) ? true:false;
  }
  bool testValidityPassword(String str){
    return (str.length == 3) ? true:false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 70),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimaryColorLowAlpha,
                        blurRadius: 20.0,
                        offset: Offset(0, 10)
                    )
                  ]
                  ,),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[100]))
                      ),
                      child: TextField(
                        controller: _emailController,
                        onChanged: (str){setState(() {
                          _validMail = testValidityMail(str);
                        });},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email adress",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          errorText: (_validMail || _emailController.value.text =="") ? null: 'Invalid email adress' ,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _passwordController,
                        onChanged: (str){setState(() {
                          _validPassword = testValidityPassword(str);
                        });},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          errorText: (_validPassword || _passwordController.value.text == "")? null: 'Invalid password',
                        ),
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  if (_validPassword && _validMail){
                    if(_validPassword){ //TODO: test if the email and password are correct here
                      Navigator.pushReplacementNamed(context, '/home');
                    } else{
                      Fluttertoast.showToast(
                          msg: 'Wrong email adress or password',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIos: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white
                      );
                    }
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top : 50, bottom: 70),
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                          colors: [
                            kPrimaryColor,
                            kPrimaryColorIntermediateAlpha,
                          ]
                      )
                  ),
                  child: Center(
                    child: Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
              Text("Forgot Password?", style: TextStyle(color: kPrimaryColor),),
            ],
          ),
        ),
      ),
    );
  }

}

class SignUpTab extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SignUpTabState();

}

class _SignUpTabState extends State<SignUpTab>{

  List <MultiSelectDialogItem<int>> multiItem = List();

  void populateMultiSelect(){
    for(int v in allClubDict.keys){
      multiItem.add(MultiSelectDialogItem(v, allClubDict[v]));
    }
  }

  bool _validName = false;
  bool _validFirstname = false;
  bool _validMail = false;
  bool _validPassword = false;

  final _nameController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool testValidityName(String str){
    return (str.length == 3) ? true:false;
  }
  bool testValidityFirstName(String str){
    return (str.length == 3) ? true:false;
  }
  bool testValidityMail(String str){
    return (str.length == 3) ? true:false;
  }
  bool testValidityPassword(String str){
    return (str.length == 3) ? true:false;
  }

  void _showMultiSelect(BuildContext context) async {
    multiItem = [];
    populateMultiSelect();
    final items = multiItem;

    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: null,
        );
      },
    );

    print(selectedValues);
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 40),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimaryColorLowAlpha,
                        blurRadius: 20.0,
                        offset: Offset(0, 10)
                    )
                  ]
                  ,),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[100]))
                      ),
                      child: TextField(
                        controller: _firstnameController,
                        onChanged: (str){setState(() {
                          _validFirstname = testValidityFirstName(str);
                        });},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Firstname",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          errorText: (_validFirstname || _firstnameController.value.text =="") ? null: 'Invalid firstname' ,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[100]))
                      ),
                      child: TextField(
                        controller: _nameController,
                        onChanged: (str){setState(() {
                          _validName = testValidityName(str);
                        });},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Name",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          errorText: (_validName || _nameController.value.text =="") ? null: 'Invalid name' ,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[100]))
                      ),
                      child: TextField(
                        controller: _emailController,
                        onChanged: (str){setState(() {
                          _validMail = testValidityMail(str);
                        });},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email adress",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          errorText: (_validMail || _emailController.value.text =="") ? null: 'Invalid email adress' ,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _passwordController,
                        onChanged: (str){setState(() {
                          _validPassword = testValidityPassword(str);
                        });},
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          errorText: (_validPassword || _passwordController.value.text =="") ? null: 'Invalid password' ,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
               margin: EdgeInsets.only(top: 20),
                child: Center(
                  child: FlatButton(
                    child: Container(
                      margin: EdgeInsets.only(left: 60, right: 60),
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Icon(Icons.apps, color: Colors.white,),
                              //margin: EdgeInsets.only(right: 5),
                            ),
                          ),
                          Expanded(child: Text("Clubs", style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)),
                          Expanded(child: SizedBox(width: 10,))
                        ],
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                              colors: [
                                kPrimaryColor,
                                kPrimaryColorIntermediateAlpha,
                              ]
                          )
                      ),
                    ),
                    onPressed: (){
                      _showMultiSelect(context);
                    },
                  )
                )
              ),
              GestureDetector(
                onTap: (){
                  if (_validPassword && _validMail && _validFirstname && _validName){
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top : 50, bottom: 70),
                  height: 50,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                          colors: [
                            kPrimaryColor,
                            kPrimaryColorIntermediateAlpha,
                          ]
                      )
                  ),
                  child: Center(
                    child: Text("Sign up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}