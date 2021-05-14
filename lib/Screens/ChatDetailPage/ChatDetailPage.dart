import 'dart:async';

import 'package:feelme/models/ChatMessageModel.dart';
import 'package:feelme/models/ChatUserModel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDetailPage extends StatefulWidget {
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  User user;
  String uid;
  String msg;
  List<ChatMessage> messages = [];
  final msgHolder = TextEditingController();
  final firestoreInstance = FirebaseFirestore.instance;
  String id;
  Future<ChatMessage> storedata(mc, mt, t) async {
    return ChatMessage(messageContent: mc, messageType: mt, time: t.toDate());
  }

  void checkchange() {
    List<ChatMessage> msg1 = [];
    firestoreInstance
        .collection("ChatRoom")
        .doc(id)
        .collection("messages")
        .orderBy('time', descending: false)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        var type = "";
        if (result.data()["content"] != null) {
          if (result.data()["user"].toString().toLowerCase() ==
              uid.toLowerCase()) {
            type = "reciever";
          } else {
            type = "sender";
          }

          var res = await storedata(
              result.data()["content"], type, result.data()["time"]);
          msg1.add(res);
        }
      });
      setState(() {
        messages = msg1;
      });
    });
  }

  var chatname;
  Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => checkchange());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  addmessage() async {
    try {
      await firestoreInstance
          .collection("ChatRoom")
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((result) {
          firestoreInstance
              .collection("ChatRoom")
              .doc(id)
              .collection("messages")
              .add({
            "content": msg,
            "user": uid,
            "time": Timestamp.fromDate(DateTime.now())
          }).then((value) {});
        });
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
  //  final firestoreInstance = FirebaseFirestore.instance;
    ChatUsers c = ModalRoute.of(context).settings.arguments;
    id = c.id;
    chatname = c.name;
    final FirebaseAuth auth = FirebaseAuth.instance;
    User user = auth.currentUser;
    uid = user.uid.toString();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  width: 2,
                ),
                CircleAvatar(
                  backgroundColor: Colors.brown.shade800,
                  child: Text('AH'),
                  maxRadius: 20,
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        chatname,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        "Online",
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: messages.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10, bottom: 60),
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                padding:
                    EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                child: Align(
                  alignment: (messages[index].messageType == "sender"
                      ? Alignment.topLeft
                      : Alignment.topRight),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: (messages[index].messageType == "sender"
                          ? Colors.grey.shade200
                          : Colors.blue[200]),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(
                      messages[index].messageContent,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      controller: msgHolder,
                      onChanged: (value) {
                        msg = value.toString();
                      },
                      decoration: InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      addmessage();
                      msgHolder.clear();
                    },
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
