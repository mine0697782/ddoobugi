import 'package:flutter/material.dart';
import 'package:frontend/screen/Login.dart';
import 'package:frontend/screen/Start.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Login(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
