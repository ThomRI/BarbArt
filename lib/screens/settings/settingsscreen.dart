import 'package:barbart/components/Sliver/headerpagesliver.dart';
import 'package:barbart/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsScreenState();

}

class _SettingsScreenState extends State<SettingsScreen>{

  Map<String, Map<String, String>> _clients;
  Map<String, Map<String, String>> _allClients = getClients();
  TextEditingController _searchController;

  static Map<String, Map<String, String>> getClients(){
    return {
      "0": {
        "name": "Name",
        "surname": "Surname",
        "status": "client",
        "avatar": "assets/logo.png"
      },
      "1": {
        "name": "Name 1",
        "surname": "Surname 1",
        "status": "client",
        "avatar": "assets/logo.png"
      },
      "2": {
        "name": "Name 2",
        "surname": "Surname 2",
        "status": "client",
        "avatar": "assets/logo.png"
      },
      "3": {
        "name": "Name 3",
        "surname": "Surname 3",
        "status": "client",
        "avatar": "assets/logo.png"
      },
      "4": {
        "name": "Name 4",
        "surname": "Surname 4",
        "status": "moderator",
        "avatar": "assets/logo.png"
      },
      "5": {
        "name": "Name 5",
        "surname": "Surname 5",
        "status": "moderator",
        "avatar": "assets/logo.png"
      },
      "6": {
        "name": "Name 6",
        "surname": "Surname 6",
        "status": "admin",
        "avatar": "assets/logo.png"
      },
      "7": {
        "name": "Name 7",
        "surname": "Surname 7",
        "status": "admin",
        "avatar": "assets/logo.png"
      },
    };
  }

  @override
  void initState(){
    _searchController = TextEditingController();
    _clients = getClients();
    print(_clients);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterSearchClients(String query) {
    print("a");
    Iterable<String> _clientsIds = _allClients.keys;
    print(_allClients);
    print(_clients);
    print(_clientsIds);
    print("h");
    if(query.isNotEmpty) {
      Map<String, Map<String, String>> _newClients = Map<String, Map<String, String>>();
      _clientsIds.forEach((item) {
        print(item);
        if(_allClients[item.toString()]["name"].contains(query) || _allClients[item.toString()]["surname"].contains(query)) {
          _newClients.addAll({item : _allClients[item]});
        }
      });
      print(_newClients);
      setState(() {
        _clients.clear();
        _clients.addAll(_newClients);
      });
    } else {
      setState(() {
        _clients.clear();
        _clients.addAll(_allClients);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
        appBar: AppBar(title: const Text('Settings'),),
        backgroundColor: Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text("Clients", textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              padding: EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width,
            ),
            Padding(
              padding: EdgeInsets.all(30),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  filterSearchClients(value);
                },
                decoration: InputDecoration(
                    labelText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: kPrimaryColor, style: BorderStyle.solid, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: (_clients != null) ? _clients.length : 0,
                  itemBuilder: (BuildContext context, int index){
                    print(_clients);
                    String idClient = _clients.keys.toList()[index];
                    print(idClient);
                    Map<String, String> map = _clients[idClient];
                    print(map);
                    String _name = map["name"];
                    String _surname = map["surname"];
                    String _status = map["status"];
                    String _avatar = map["avatar"];
                    return ListTile(
                      title: Text("$_name $_surname"),
                      //subtitle: Text("$_status"),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage(_avatar),
                      ),
                      trailing: DropdownButton(
                        items: [
                          DropdownMenuItem(
                            value: "client",
                            child: Text("C",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey,)
                            )
                          ),
                          DropdownMenuItem(
                            value: "moderator",
                            child: Text("M",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.blue,)
                            )
                          ),
                          DropdownMenuItem(
                              value: "admin",
                              child: Text("A",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.deepOrangeAccent,)
                            )
                          ),
                        ],
                        onChanged: (value){
                          setState(() {
                            _clients[idClient.toString()]["status"] = value;
                          });
                        },
                        value: _status,
                        icon: Container(),
                        underline: Container(),
                      ),
                    );
                  }
              ),
            ),
          ],
        )
    ),
    );
  }

}