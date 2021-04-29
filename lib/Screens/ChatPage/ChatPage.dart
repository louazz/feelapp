import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'package:feelme/widgets/ConversationList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:feelme/models/ChatUserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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
    LocationPermission permission = await Geolocator.requestPermission();
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

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void checkchange() {
    List<ChatUsers> cu = [];
    try {
      firestoreInstance
          .collection("ChatRoom")
          .orderBy('time', descending: false)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          print(result.data()["time"]);
          var data = result.data();
          print(result.id);
          Position p = data["geo"];
          double d = calculateDistance(p.longitude, p.latitude,
              _currentPosition.longitude, _currentPosition.latitude);
          if (d < _distance) {
            setState(() {
              cu.add(ChatUsers(
                  name: data["name"].toString(),
                  messageText: data["Slogon"].toString(),
                  imageURL: imageURL,
                  time: DateTime.fromMillisecondsSinceEpoch(data["time"])
                      .toString(),
                  id: result.id));
            });
          }
        });
      });
    } catch (e) {
      print(e);
    }
    setState(() {
      chatUsers = cu;
    });
  }

  final firestoreInstance = FirebaseFirestore.instance;
  @override
  void initState() {
    try {
      _getCurrentLocation();
    } catch (e) {
      print(e);
    }
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => checkchange());
    super.initState();
  }

  static const imageURL = "assets/images/icon1.jpeg";

  @override
  Widget build(BuildContext context) {
    final firestoreInstance = FirebaseFirestore.instance;

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
                                                _currentPosition.altitude,
                                                _currentPosition.longitude)
                                          }).then((value) {
                                            print(value.id);
                                            firestoreInstance
                                                .collection("ChatRoom")
                                                .doc(value.id)
                                                .collection("messages");
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
