import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: size.width * 0.95,
            height: size.height * 0.2,
            padding: EdgeInsets.only(left: size.width * 0.65),
            child: const Text(
              "뚜버기",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Hanbit",
                fontSize: 40,
              ),
            ),
          )
        ],
      ),
    );
  }
}
