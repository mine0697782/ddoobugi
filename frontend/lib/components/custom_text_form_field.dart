import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final Size size;
  final TextEditingController ID;
  final String text;
  final bool isCheckPass;
  final String password;
  final bool isCheckEmail;
  const CustomTextFormField({
    required this.size,
    required this.ID,
    required this.text,
    this.isCheckPass = false,
    this.password = "",
    this.isCheckEmail = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size.width * 0.7,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromRGBO(237, 237, 237, 80)),
        padding: const EdgeInsets.only(left: 20),
        child: TextFormField(
            controller: ID,
            decoration: InputDecoration(
                hintText: text,
                labelText: text,
                border: InputBorder.none,
                errorStyle: const TextStyle(color: Colors.red)),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
            validator: (value) {
              if (value!.isEmpty) {
                return "필수항목입니다";
              } else {
                if (isCheckPass) {
                  if (value == password) {
                    return null;
                  } else {
                    return "비밀번호가 같지 않습니다.";
                  }
                }
                if (isCheckEmail) {
                  return "이메일 중복";
                }
                return null;
              }
            }));
  }
  // @override
  // Widget build(BuildContext context) {
  //   final Size size = MediaQuery.of(context).size;
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       TextFormField(
  //         // 1. [유효성 체크]
  //         // 공백일 경우 메시지 출력..
  //         validator: (value) => value!.isEmpty ? "필수항목입니다" : null,

  //         // 2. [마킹처리]
  //         // text가 Password일 경우 마킹 처리 true
  //         obscureText: text == "Password" ? true : false,

  //         // 3. [데코레이션]
  //         // 힌트 문자나 여러가지 데코레이션 기능 추가
  //         decoration: InputDecoration(
  //             hintText: text, // 힌트문자
  //             fillColor: const Color.fromRGBO(237, 237, 237, 80),
  //             enabledBorder: OutlineInputBorder(
  //               // 기본 모양
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             focusedBorder: OutlineInputBorder(
  //               // 포커스 되었을 경우 모양
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             errorBorder: OutlineInputBorder(
  //                 // 에러 발생 시 모양
  //                 borderRadius: BorderRadius.circular(10)),
  //             focusedErrorBorder: OutlineInputBorder(
  //                 // 에러 발생 후 포커스 되었을 경우 모양
  //                 borderRadius: BorderRadius.circular(10))),
  //         style: const TextStyle(
  //           color: Colors.black,
  //           fontSize: 15,
  //         ),
  //       )
  //     ],
  //   );
  // }
}
