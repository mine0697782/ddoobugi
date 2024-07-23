import 'package:flutter/material.dart';
import 'package:frontend/components/custom_text_form_field.dart';
import 'package:frontend/components/size.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController ID = TextEditingController();
  TextEditingController PASSWORD = TextEditingController();
  TextEditingController EMAIL = TextEditingController();
  TextEditingController CHECKPASSWORD = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.only(left: size.width * 0.7, top: size.width * 0.05),
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
              "회원가입",
              style: TextStyle(
                color: Colors.black,
                fontFamily: "Hanbit",
                fontSize: 30,
              ),
            ),
          ),
          SizedBox(
            height: size.height * small_gap,
          ),
          CustomTextFormField(size: size, ID: EMAIL, text: "이메일 주소"),
          SizedBox(
            height: size.height * small_gap,
          ),
          CustomTextFormField(size: size, ID: ID, text: "사용자 이름"),
          SizedBox(
            height: size.height * small_gap,
          ),
          CustomTextFormField(size: size, ID: PASSWORD, text: "비밀번호"),
          SizedBox(
            height: size.height * small_gap,
          ),
          CustomTextFormField(size: size, ID: CHECKPASSWORD, text: "비밀번호 확인"),
          SizedBox(
            height: size.height * 0.05,
          ),
          SizedBox(
            width: size.width * 0.7,
            height: size.width * 0.08,
            child: TextButton(
                onPressed: () {
                  setState() {}
                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ))
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(28, 181, 224, 0.686),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "회원가입",
                  style: TextStyle(fontSize: 15, color: Colors.white),
                )),
          ),
        ],
      ),
    );
  }
}
