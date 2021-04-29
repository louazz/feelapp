import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentUser extends ChangeNotifier {
  String _uid;
  String _email;

  String get getUid => _uid;
  String get getEmail => _email;

  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signOut() async {
    bool retVal = false;

    try {
      await _auth.signOut();
      retVal = true;
    } catch (e) {
      print(e);
    }
    return retVal;
  }

  Future<bool> signUpUser(String email, String password) async {
    bool retVal = false;
    try {
      UserCredential _authResult = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      if (_authResult.user != null) {
        retVal = true;
      }
    } catch (e) {
      print(e);
    }

    return retVal;
  }

  Future<bool> loginUserWithEmail(String email, String password) async {
    bool retVal = false;

    try {
      await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);

      retVal = true;
    } catch (e) {
      print(e);
    }

    return retVal;
  }
}
