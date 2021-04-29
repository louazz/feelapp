import 'package:flutter/material.dart';
import 'package:feelme/Screens/Welcome/welcome_screen.dart';
import 'package:feelme/constants.dart';
import 'package:provider/provider.dart';
import 'package:feelme/states/CurrentUser.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CurrentUser(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Auth',
          theme: ThemeData(
            primaryColor: kPrimaryColor,
            scaffoldBackgroundColor: Colors.white,
          ),
          home: WelcomeScreen(),
        ));
  }
}
