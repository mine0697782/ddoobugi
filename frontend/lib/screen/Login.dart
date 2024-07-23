import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'Signup.dart';
import 'package:frontend/components/custom_text_form_field.dart';
import 'package:frontend/components/size.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController ID = TextEditingController();
  TextEditingController PASSWORD = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: _formkey,
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
              height: size.height * 0.15,
            ),
            Padding(
              padding: EdgeInsets.only(right: size.width * 0.53),
              child: const Text(
                "로그인",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "Hanbit",
                  fontSize: 30,
                ),
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            CustomTextFormField(size: size, ID: ID, text: "아이디"),
            SizedBox(
              height: size.height * small_gap,
            ),
            CustomTextFormField(size: size, ID: PASSWORD, text: "비밀번호"),
            SizedBox(
              height: size.height * 0.05,
            ),
            SizedBox(
              width: size.width * 0.7,
              height: size.width * 0.08,
              child: TextButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => ))
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(28, 181, 224, 0.686),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "로그인",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  )),
            ),
            SizedBox(
              height: size.height * 0.2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "아이디가 없으시다면?",
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(
                  width: 10,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Signup()));
                  },
                  child: const Text(
                    "회원가입",
                    style: TextStyle(fontSize: 15, color: Colors.black),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
