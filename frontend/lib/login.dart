import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController ID = TextEditingController();
  TextEditingController PASSWORD = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: size.width * 1,
        height: size.height * 1,
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: size.width * 0.7, top: size.width * 0.05),
              child: const Text(
                "뚜벅이",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Hanbit",
                  fontSize: 40,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.1,
            ),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.55),
              child: const Text(
                "로그인",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Hanbit",
                  fontSize: 25,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.1,
            ),
            Container(
              width: size.width * 0.7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(237, 237, 237, 80)),
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
                controller: ID,
                decoration: const InputDecoration(
                  hintText: "아이디",
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            Container(
              width: size.width * 0.7,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color.fromRGBO(237, 237, 237, 80)),
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
                controller: PASSWORD,
                decoration: const InputDecoration(
                  hintText: "비밀번호",
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
          ],
        ),
      ),
    );
  }
}
