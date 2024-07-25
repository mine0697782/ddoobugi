import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/custom_text_form_field.dart';
import 'package:frontend/components/server.dart';
import 'package:frontend/components/size.dart';
import 'package:frontend/screen/Login.dart';
import 'package:http/http.dart' as http;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

Future<String> fetchInfo(
    BuildContext context, Map<String, String> userData) async {
  var url = "$serverUrl/register";
  //서버에 보내는 폼
  final response = await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(userData), //실질적 데이터
  );

  //응답에 따라 구분. 200코드면 잘 된 것.
  try {
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData =
          jsonDecode(utf8.decode(response.bodyBytes));
      String result = responseData['result'];
      return result;
    }
    return 'fail';
  } catch (e) {
    rethrow;
  }
}

class _SignupState extends State<Signup> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController ID = TextEditingController();
  TextEditingController PASSWORD = TextEditingController();
  TextEditingController EMAIL = TextEditingController();
  TextEditingController CHECKPASSWORD = TextEditingController();
  bool isCheckEmail = false;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
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
                CustomTextFormField(
                  size: size,
                  ID: EMAIL,
                  text: "이메일 주소",
                  isCheckEmail: isCheckEmail,
                ),
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
                CustomTextFormField(
                  size: size,
                  ID: CHECKPASSWORD,
                  text: "비밀번호 확인",
                  isCheckPass: true,
                  password: PASSWORD.text,
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                SizedBox(
                  width: size.width * 0.7,
                  height: size.width * 0.08,
                  child: TextButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          if (CHECKPASSWORD.text == PASSWORD.text) {
                            Map<String, String> userData = {
                              'email': EMAIL.text,
                              'password': PASSWORD.text,
                              'name': ID.text,
                            };
                            print("회원가입");
                            fetchInfo(context, userData).then((data) {
                              print("데이터 통신");
                              if (data == "success") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ),
                                );
                              } else if (data == "email already exist") {
                                setState(() {
                                  isCheckEmail = true;
                                });
                              }
                            });
                          }
                        }
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => ))
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(28, 181, 224, 0.686),
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
          ),
        ),
      ),
    );
  }
}
