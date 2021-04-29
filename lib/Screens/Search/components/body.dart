import 'package:flutter/material.dart';
import 'package:feelme/Screens/Welcome/components/background.dart';
import 'package:flutter_svg/svg.dart';
import 'package:feelme/components/rounded_button.dart';
import 'package:feelme/components/item_container.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              "assets/icons/fire.svg",
              height: size.height * 0.1,
            ),
            SizedBox(height: size.height * 0.05),
            RoundedButton(text: "Search", press: () {}),
            SizedBox(height: size.height * 0.05),
            ItemContainer(
              child: Text("Lobby One"),
            ),
            ItemContainer(
              child: Text("Lobby One"),
            ),
            ItemContainer(
              child: Text("Lobby One"),
            ),
          ],
        ),
      ),
    );
  }
}
