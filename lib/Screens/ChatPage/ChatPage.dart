import 'dart:async';
import 'package:feelme/widgets/ConversationList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feelme/models/ChatUserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatUsers> chatUsers = [];
  Position _currentPosition;
  TextEditingController newgroupename = new TextEditingController();
  TextEditingController newgroupeslogon = new TextEditingController();

  var _distance = 2;
  Timer timer;
  _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }

  final geo = Geoflutterfire();
  final firestoreInstance = FirebaseFirestore.instance;
  Future<void> checkchange() async {
    try {
      _getCurrentLocation();
      List<ChatUsers> cu = [];

      firestoreInstance.collection('ChatRoom').get().then((querySnapshot) {
        querySnapshot.docs.forEach((result) async {
          var data = result.data();
          GeoPoint p = data["goe"];
          print(data["goe"].longitude.toString());
          double d = Geolocator.bearingBetween(p.longitude, p.latitude,
              _currentPosition.longitude, _currentPosition.latitude);
          Timestamp t = data["time"];
          if (d < _distance) {
            setState(() {
              cu.add(ChatUsers(
                  name: data["name"].toString(),
                  messageText: data["Slogon"].toString(),
                  imageURL: imageURL,
                  time: t.toDate(),
                  pos: data["geo"],
                  id: result.id));
            });
          }
        });
        setState(() {
          chatUsers = cu;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void checker() {
    print(_currentPosition.toString());
// Create a geoFirePoint
    GeoFirePoint center = geo.point(latitude: 34.4739, longitude: 9.4613);
    print(center.latitude.toString());
// get the collection reference or query
    var collectionReference = firestoreInstance.collection('ChatRoom');
    double radius = 12;
    try {
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(collectionRef: collectionReference)
          .within(center: center, radius: 12, field: "goe");

      stream.listen((List<DocumentSnapshot> documentList) {
        print(documentList.isEmpty.toString());
        documentList.forEach((result) {
          var data = result.data();
          print(result.toString());
          Timestamp t = data["time"];
          setState(() {
            chatUsers.add(ChatUsers(
                name: data["name"].toString(),
                messageText: data["Slogon"].toString(),
                imageURL: imageURL,
                time: t.toDate(),
                pos: data["geo"],
                id: result.id));
          });
        });
      });
    } catch (e) {
      print(e);
    }
  }
  // var checker = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    timer = Timer.periodic(Duration(seconds: 20), (Timer t) => checkchange());
  }

  // timer = Timer.periodic(Duration(seconds:40), (Timer t) => checkchange());
  static const imageURL = "assets/images/icon1.png";

  @override
  Widget build(BuildContext context) {
    // final firestoreInstance = FirebaseFirestore.instance;

    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "Conversations",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding:
                          EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.pink[50],
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 2,
                          ),
                          Icon(
                            Icons.add,
                            color: Colors.pink,
                            size: 20,
                          ),
                          TextButton(
                            child: null,
                            style:
                                TextButton.styleFrom(primary: Colors.blueGrey),
                            onPressed: () {
                              showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: Text('Create a groupe'),
                                    content: Card(
                                      color: Colors.transparent,
                                      elevation: 0.0,
                                      child: Column(
                                        children: <Widget>[
                                          TextField(
                                            controller: newgroupename,
                                            decoration: InputDecoration(
                                              labelText: "Name",
                                              filled: true,
                                            ),
                                          ),
                                          TextField(
                                            controller: newgroupeslogon,
                                            decoration: InputDecoration(
                                              labelText: "Slogon",
                                              filled: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[
                                      CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text("Confirm"),
                                        onPressed: () {
                                          firestoreInstance
                                              .collection("ChatRoom")
                                              .add({
                                            "name": newgroupename.text,
                                            "Slogon": newgroupeslogon.text,
                                            "time": Timestamp.fromDate(
                                                DateTime.now()),
                                            "goe": new GeoPoint(
                                                _currentPosition.latitude,
                                                _currentPosition.longitude)
                                          });
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search...",
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.shade100)),
                ),
              ),
            ),
            ListView.builder(
              itemCount: chatUsers.length,
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return ConversationList(
                  name: chatUsers[index].name,
                  messageText: chatUsers[index].messageText,
                  imageUrl: chatUsers[index].imageURL,
                  time: chatUsers[index].time,
                  isMessageRead: (index == 0 || index == 3) ? true : false,
                  id: chatUsers[index].id,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getCurrentLocation();
          showCupertinoDialog(
              context: context,
              builder: (BuildContext context) {
                return StatefulBuilder(builder: (context, setState) {
                  return CupertinoAlertDialog(
                    title: Text("Distance: $_distance"),
                    content: CupertinoSlider(
                        value: _distance.toDouble(),
                        onChanged: (double ne) {
                          setState(() {
                            _distance = ne.round();
                          });
                        },
                        min: 0,
                        max: 100),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                });
              });
        },
        child: const Icon(Icons.navigation),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }
}
