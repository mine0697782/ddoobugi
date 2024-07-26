import 'package:flutter/material.dart';
import 'package:frontend/components/User.dart';
import 'package:frontend/screen/Login.dart';
import 'package:frontend/screen/Start.dart';
import 'package:frontend/screen/Map.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(
          userdata: User(
              Usertoken:
                  "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IjEyMyIsImV4cCI6MTcyMzExMTc2OX0.PtU9eUoXtngMStHVbFgdl14uFZfrf1_bQAbf-NB2sWw")),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
