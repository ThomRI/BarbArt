import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../multiSelectDialog.dart';

GlobalKey<ProfileScreenState> profileScreenKey = GlobalKey<ProfileScreenState>();


class ProfileScreen extends StatefulWidget {

  ProfileScreen() : super(key: profileScreenKey);

  @override
  State<StatefulWidget> createState() => ProfileScreenState();

}

class ProfileScreenState extends State<ProfileScreen>{


  PickedFile _image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = PickedFile(pickedFile.path);
    });
  }

  bool receiveNotifications = true;

  final double pi = 3.141592653589793;

  @override
  Widget build(BuildContext context) {


    List <MultiSelectDialogItem<int>> multiItem = List();

    // List of all clubs
    final valuesToPopulate = {
      1 : "Cuisine",
      2 : "Cinéma",
      3 : "Photo",
    };


    var selectedClubs = new List<String>();
    var _initialValuesString = new List<String>();
    var _initialValuesInt = new List<int>();

    // TODO: change this function so that it uses server based data and not sharedPreferences
    void getInitialValues() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getStringList('initialValues')!= null){
        _initialValuesString = prefs.getStringList('initialValues');
      }
      else {
        prefs.setStringList('initialValues', new List<String>());
      }

      for(String x in _initialValuesString.toList()){
        _initialValuesInt.add(int.parse(x));
        selectedClubs.add(valuesToPopulate[x]);
      }
    }

    void populateMultiSelect(){
      for(int v in valuesToPopulate.keys){
        multiItem.add(MultiSelectDialogItem(v, valuesToPopulate[v]));
      }
    }

    void _showMultiSelect(BuildContext context) async {
      multiItem = [];
      getInitialValues();
      populateMultiSelect();
      final items = multiItem;

      // TODO: instead of SharedPreferences, get values from server or local data
      SharedPreferences prefs = await SharedPreferences.getInstance();

      final selectedValues = await showDialog<Set<int>>(
        context: context,
        builder: (BuildContext context) {
          return MultiSelectDialog(
            items: items,
            initialSelectedValues: _initialValuesInt.toSet(),
          );
        },
      );

      setState((){

        var _selectedValuesString = List<String>();
        final _selectedValuesInt = selectedValues.toList();
        for(int x in _selectedValuesInt){
          _selectedValuesString.add(x.toString());
        }
        // TODO: Update values in SQL server
        prefs.setStringList('initialValues', _selectedValuesString);

      });}

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Profile'),),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    //color: Colors.red,
                    child: Transform.rotate(
                      angle: pi/5,
                      child: Image(
                        width: 120,
                        height: 120,
                        image:AssetImage('assets/images/pickaxe.png'),
                      ),
                    ),
                  ),
                  Container(
                    //color: Colors.blue,
                    child: Transform.rotate(
                      angle: -pi/5,
                      child: Image(
                        width: 120,
                        height: 120,
                        image:AssetImage('assets/images/boule_pics.png'),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        height: (MediaQuery.of(context).orientation == Orientation.portrait) ? 80: 40,
                      ),
                      CircleAvatar(
                        backgroundImage: _image ?? AssetImage('assets/logo.png'),
                        radius: 80,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimaryColor,
                            ),
                            child: IconButton(
                              icon: Icon(
                                  Icons.edit
                              ),
                              onPressed: getImage,
                              tooltip: 'Pick Image',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.all(5),
                          child: Text('Surname Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                      ),
                      Container(
                        child: Text('emailadress@gmail.com', style: TextStyle(fontSize: 12),),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: (MediaQuery.of(context).orientation == Orientation.portrait) ? 50: 30,
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: SwitchListTile(
                      onChanged: (bool){
                        setState(() {
                          receiveNotifications = bool;
                        });
                      }, //TODO: implement onChanged function
                      title: Text('Receive notifications'),
                      value: receiveNotifications,
                      activeColor: kPrimaryColor,
                    ),
                  ),
                  // TODO: Add on pressed functions
                  ProfileButton(title: 'Change password', negativeColors: true, marginTop: 30, iconData: Icons.lock, onPressed: (context){},),
                  ProfileButton(title: 'Clubs you follow' , negativeColors: true, marginTop: 30, marginBottom: 30, iconData: Icons.apps, onPressed: _showMultiSelect),
                  ProfileButton(title: 'Log out' , marginTop: 30, marginBottom: 50, iconData: Icons.person, onPressed: (context){Navigator.popUntil(context, ModalRoute.withName('/home'));Navigator.of(context).pushReplacementNamed('/login');},),
                ],
              ),
            ],
          ),
        ),
      ),);
  }

}

class ProfileButton extends StatelessWidget{

  final String title;
  final IconData iconData;
  final onPressed;
  final double marginTop;
  final double marginBottom;
  final bool negativeColors;

  const ProfileButton({Key key, this.title = "", this.onPressed, this.iconData = Icons.remove, this.marginTop = 0, this.marginBottom = 0, this.negativeColors = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   return GestureDetector(
     onTap: () => onPressed(context),
     child: Container(
       margin: EdgeInsets.only(right:30, left: 30, bottom: marginBottom ?? 0, top: marginTop ?? 0),
       padding: EdgeInsets.all(15),
       decoration: BoxDecoration(
           borderRadius: BorderRadius.circular(10),
           border: Border.all(
             color: negativeColors ? kPrimaryColor : Colors.white,
             style: BorderStyle.solid,
             width: 1
           ),
           gradient: LinearGradient(
               colors: negativeColors ? [Colors.white, Colors.white] : [
                 kPrimaryColor,
                 kPrimaryColorIntermediateAlpha,
               ]
           )
       ),
       child: Center(
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: <Widget>[
             Container(
               padding: EdgeInsets.only(left: 10, right: 10),
               child: Icon(iconData, color: negativeColors ? kPrimaryColor : Colors.white,)
             ),
             Text(title, style: TextStyle(color: negativeColors ? kPrimaryColor : Colors.white, fontWeight: FontWeight.bold),),
             SizedBox(width: 40,)
           ],
         ),
       ),
     ),
   );
  }

}