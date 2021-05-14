import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class ChatUsers {
  String name;
  String messageText;
  String imageURL;
  DateTime time;
  GeoPoint pos;

  String id;
  ChatUsers(
      {@required this.name,
      @required this.messageText,
      @required this.imageURL,
      @required this.time,
      @required this.pos,
      this.id});
}
