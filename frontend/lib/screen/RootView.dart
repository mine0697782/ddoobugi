import 'package:flutter/material.dart';
import 'package:frontend/components/app_theme.dart';

class RootviewScreen extends StatefulWidget {
  const RootviewScreen({super.key});

  @override
  State<RootviewScreen> createState() => _RootviewScreenState();
}

class _RootviewScreenState extends State<RootviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "내가 가는 길",
                  style: TextStyle(fontFamily: "Hanbit", fontSize: 30),
                ),
              ),
            ),
            //지도 들어가기
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey,
            ),
            const SizedBox(
              height: 20,
            ),
            //따라가기 버튼
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    '따라가기',
                    style: TextStyle(
                        fontFamily: "Hanbit",
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
