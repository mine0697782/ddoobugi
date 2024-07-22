import 'package:flutter/material.dart';

const String appTitle = "뚜벅이";

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Container(
              // width: size.width * 0.8,
              // height: size.height * 0.2,
              width: 100,
              height: 100,
              padding:
                  const EdgeInsets.only(left: 50, right: 5, top: 5, bottom: 5),
              child: const Text(
                appTitle,
                style: TextStyle(fontFamily: "Hanbit", color: Colors.black),
              ),
            ),
            const Text("dkdkkdkdkddkk")
          ],
        ),
      ),
    );
  }
}
