import 'package:barbart/constants.dart';
import 'package:barbart/multiSelectDialog.dart';
import 'package:barbart/pages/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
            title: Text("Log in"),
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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
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
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email or Phone number",
                          hintStyle: TextStyle(color: Colors.grey[400])
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey[400])
                      ),
                    ),
                  )
                ],
              ),
            ),
            GestureDetector(
              onTap: (){},
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
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
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
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Firstname",
                          hintStyle: TextStyle(color: Colors.grey[400])
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[100]))
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Name",
                          hintStyle: TextStyle(color: Colors.grey[400])
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey[100]))
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Email or Phone number",
                          hintStyle: TextStyle(color: Colors.grey[400])
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey[400])
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
              onTap: (){},
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
    );
  }

}