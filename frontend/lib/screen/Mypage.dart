import 'package:flutter/material.dart';
import 'package:frontend/components/app_theme.dart';
import 'package:frontend/screen/Login.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Container(
        child: TextButton(
          child: const Text("로그아웃"),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Login()));
          },
        ),
      ),
    );
  }
}
