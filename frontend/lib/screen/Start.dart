import 'package:flutter/material.dart';
import 'package:frontend/screen/Map.dart';
import 'package:permission_handler/permission_handler.dart';

class StartSreen extends StatelessWidget {
  const StartSreen({super.key});

  Future<void> requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => mapScreen()),
      );
    } else {
      // 권한이 거부되었을 때의 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('위치 권한이 필요합니다.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          '../assets/images/logo.png',
          scale: 6,
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "뚜벅이",
              style: TextStyle(fontFamily: "Hanbit", fontSize: 40),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              "당신의 즉흥을 따라가볼게요",
              style: TextStyle(fontFamily: "Hanbit", fontSize: 20),
            ),
            const Text(
              "가고 싶은 길이 있나요?",
              style: TextStyle(fontFamily: "Hanbit", fontSize: 20),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFADEEFF),
                fixedSize: const Size(250, 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                requestLocationPermission(context);
              },
              child: const Text(
                "지금 위치에서 출발하기",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Hanbit',
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBFFFC6),
                fixedSize: const Size(250, 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadowColor: Colors.grey,
              ),
              onPressed: () {},
              child: const Text(
                "이전 기록따라 움직이기",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Hanbit',
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
