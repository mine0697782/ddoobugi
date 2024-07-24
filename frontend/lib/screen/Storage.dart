import 'package:flutter/material.dart';
import 'package:frontend/screen/StorageView.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  bool _isEditing = false; // 편집 모드를 관리하는 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          scale: 6,
        ),
        shadowColor: Colors.grey,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing; // 편집 모드 전환
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Divider(
            height: 0.8,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          storage(context, _isEditing),
          storage(context, _isEditing),
          storage(context, _isEditing),
          storage(context, _isEditing),
          storage(context, _isEditing),
          storage(context, _isEditing),
          storage(context, _isEditing),
          storage(context, _isEditing),
          storage(context, _isEditing),
          storage(context, _isEditing),
        ],
      ),
    );
  }
}

Widget storage(BuildContext context, bool isEditing) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => StorageView()));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.9), // 왼쪽 더 어두운 필터
                    Colors.transparent, // 오른쪽 투명
                  ],
                ).createShader(bounds),
                blendMode: BlendMode.darken,
                child: Image.asset(
                  "assets/images/sample1.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
      // 루트 이름
      Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.fromLTRB(30, 25, 15, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "내가 가는 길",
              style: TextStyle(
                fontFamily: "Hanbit",
                fontSize: 28,
                color: Colors.white,
              ),
            ),
            Text(
              "위치: 서울 성북구 정릉로 77",
              style: TextStyle(
                fontFamily: "Hanbit",
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      // 삭제 버튼
      if (isEditing)
        Positioned(
          right: 16,
          top: 16,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () {
              // 아이템 삭제 로직 추가
            },
          ),
        ),
    ],
  );
}
