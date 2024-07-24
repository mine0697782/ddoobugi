import 'package:flutter/material.dart';

class RootviewScreen extends StatefulWidget {
  const RootviewScreen({super.key});

  @override
  State<RootviewScreen> createState() => _RootviewScreenState();
}

class _RootviewScreenState extends State<RootviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          scale: 6,
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Divider(
            height: 0.8,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
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
            SizedBox(
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
                  child: Text(
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
