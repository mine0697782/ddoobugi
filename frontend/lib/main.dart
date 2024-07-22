import 'package:flutter/material.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "뚜버기",
        style: TextStyle(
          fontFamily: 'Hanbit',
        ),
      )),
      body: Container(),
    );
  }
}
