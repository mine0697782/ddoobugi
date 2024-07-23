import 'package:flutter/material.dart';
import 'package:frontend/screen/Map.dart';
import 'package:frontend/screen/Start.dart';

import 'screen/login.dart';

void main() {
  runApp(const Main());
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: mapScreen(),
    );
  }
}
