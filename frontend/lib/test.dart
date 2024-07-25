// import 'dart:convert';
// import 'package:dodo/components/l_title.dart';
// import 'package:dodo/const/colors.dart';
// import 'package:dodo/const/server.dart';
// import 'package:dodo/screen/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:validators/validators.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// Future<int> fetchInfo(
//     BuildContext context, Map<String, String> userData) async {
//   var url = '$serverUrl/api/v1/users/register';
//   //서버에 보내는 폼
//   final response = await http.post(
//     Uri.parse(url),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(userData), //실질적 데이터
//   );
//   try {
//     //응답에 따라 구분. 200코드면 잘 된 것.
//     if (response.statusCode == 200) {
//       print('회원가입 성공!');
//       Map<String, dynamic> responseData =
//           jsonDecode(utf8.decode(response.bodyBytes));
//       int userId = responseData['userId'];
//       print('userid: $userId'); // log 찍는 걸로 차후에 변경하기
//       return userId;
//     } else {
//       String errorMessage =
//           jsonDecode(utf8.decode(response.bodyBytes))['message'];
//       print('회원가입 실패: $errorMessage');
//       //실패시 dialog로 보여줌.
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('회원가입 실패'),
//             content: Text(errorMessage),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const Text('확인'),
//               ),
//             ],
//           );
//         },
//       );
//       throw Exception('회원가입에 실패했습니다');
//     }
//   } catch (e) {
//     //오류
//     print(response.body);
//     print('네트워크 오류: $e');
//     throw Exception('네트워크 오류가 발생했습니다');
//   }
// }

// class _SignupPageState extends State<SignupPage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final TextEditingController _email = TextEditingController();
//   final TextEditingController _username = TextEditingController();
//   final TextEditingController _password1 = TextEditingController();
//   final TextEditingController _password2 = TextEditingController();
//   bool _obscurePassword1 = true;
//   bool _obscurePassword2 = true;

//   @override
//   void dispose() {
//     _email.dispose();
//     _username.dispose();
//     _password1.dispose();
//     _password2.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ButtonStyle style = ElevatedButton.styleFrom(
//       backgroundColor: PRIMARY_COLOR,
//       textStyle: const TextStyle(fontSize: 20),
//       minimumSize: const Size(300, 70),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//     );

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(120),
//         child: Container(
//           width: 100,
//           height: 100,
//           alignment: Alignment.topRight,
//           padding: const EdgeInsets.fromLTRB(0, 30, 30, 0),
//           child: const Image(
//             image: AssetImage('assets/images/logo.png'),
//             width: 110,
//             height: 110,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 50),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     const l_title("회원가입"),
//                     const SizedBox(height: 20),
//                     // 이메일
//                     TextFormField(
//                       controller: _email,
//                       keyboardType: TextInputType.emailAddress,
//                       style: const TextStyle(fontSize: 20),
//                       decoration: const InputDecoration(
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(20)),
//                           borderSide: BorderSide.none,
//                         ),
//                         labelText: '이메일 주소',
//                         filled: true,
//                         fillColor: Color(0xffEDEDED),
//                         labelStyle:
//                             TextStyle(color: Color(0xff4f4f4f), fontSize: 18),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return '이메일을 입력해주세요.';
//                         }
//                         if (!isEmail(value.trim())) {
//                           return '이메일 형식이 맞지 않습니다';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     // 사용자이름
//                     TextFormField(
//                       controller: _username,
//                       keyboardType: TextInputType.name,
//                       style: const TextStyle(fontSize: 20),
//                       decoration: InputDecoration(
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(20)),
//                           borderSide: BorderSide.none,
//                         ),
//                         labelText: '사용자이름',
//                         filled: true,
//                         fillColor: const Color(0xffEDEDED),
//                         labelStyle: TextStyle(color: DARKGREY, fontSize: 18),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return '사용하실 이름을 입력해주세요.';
//                         }
//                         if (value.length < 2) {
//                           return '2글자 이상 입력해주세요.';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     // 비밀번호
//                     TextFormField(
//                       controller: _password1,
//                       keyboardType: TextInputType.visiblePassword,
//                       style: const TextStyle(fontSize: 20),
//                       obscureText: _obscurePassword1,
//                       decoration: InputDecoration(
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(20)),
//                           borderSide: BorderSide.none,
//                         ),
//                         labelText: '비밀번호',
//                         filled: true,
//                         fillColor: const Color(0xffEDEDED),
//                         labelStyle: const TextStyle(
//                             color: Color(0xff4f4f4f), fontSize: 18),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword1
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword1 = !_obscurePassword1;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return '비밀번호를 입력하세요.';
//                         }
//                         if (value.length < 6) {
//                           return '6글자 이상 입력해주세요.';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     // 비밀번호 확인
//                     TextFormField(
//                       controller: _password2,
//                       keyboardType: TextInputType.visiblePassword,
//                       style: const TextStyle(fontSize: 20),
//                       obscureText: _obscurePassword2,
//                       decoration: InputDecoration(
//                         border: const OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(20)),
//                           borderSide: BorderSide.none,
//                         ),
//                         labelText: '비밀번호확인',
//                         filled: true,
//                         fillColor: const Color(0xffEDEDED),
//                         labelStyle: const TextStyle(
//                             color: Color(0xff4f4f4f), fontSize: 18),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword2
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword2 = !_obscurePassword2;
//                             });
//                           },
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.trim().isEmpty) {
//                           return '비밀번호를 입력하세요.';
//                         }
//                         if (_password1.text != value) {
//                           return '패스워드 불일치';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       style: style,
//                       onPressed: () {
//                         //회원가입 버튼 클릭시
//                         if (_formKey.currentState!.validate()) {
//                           //controller text들 mapping
//                           Map<String, String> userData = {
//                             'type': 'password',
//                             'email': _email.text,
//                             'username': _username.text,
//                             'password1': _password1.text,
//                             'password2': _password2.text,
//                           };
//                           //fetchInfo 실행.
//                           fetchInfo(context, userData).then((data) {
//                             print("로그인으로 넘어감");
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => loginPage(userId: data),
//                               ),
//                             );
//                           }).catchError((error) {
//                             print("망할 에러$error");
//                             print("$userData");
//                           });
//                         }
//                       },
//                       child: const Text(
//                         '회원가입',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 15),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => loginPage()));
//               },
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xff464646),
//               ),
//               child: const Text(
//                 '아이디가 있다면? 로그인하기',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ),
//             Container(
//               alignment: Alignment.bottomCenter,
//               child: Image.asset('assets/images/turtle_w_e.png',
//                   fit: BoxFit.fill, alignment: Alignment.bottomCenter),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
