import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/components/server.dart';
import 'package:frontend/screen/StorageView.dart';
import 'package:http/http.dart' as http;

Future<bool> deleteStorage(String id) async {
  var headers = {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IjEyMyIsImV4cCI6MTcyMzExMTc2OX0.PtU9eUoXtngMStHVbFgdl14uFZfrf1_bQAbf-NB2sWw',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final response = await http.post(
    Uri.parse('$serverUrl/routes/$id/delete'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    log("삭제 됨");
    return true; // 성공적으로 삭제됨
  } else {
    log("아이템 삭제 실패: ${response.body}");
    return false; // 삭제 실패
  }
}

Future<List<Storage_form>> fetchStorage() async {
  var headers = {
    'Authorization':
        'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6IjEyMyIsImV4cCI6MTcyMzExMTc2OX0.PtU9eUoXtngMStHVbFgdl14uFZfrf1_bQAbf-NB2sWw',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final response = await http.get(
    Uri.parse(serverUrl + '/routes'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
    // 응답에서 'routes' 필드를 추출
    var storeList = jsonResponse['data'] as List;
    List<Storage_form> stores =
        storeList.map((storeJson) => Storage_form.fromJson(storeJson)).toList();
    log("/routes 불러옴");
    return stores;
  } else {
    log("/routes 부르려 했는데 실패");
    log(jsonDecode(utf8.decode(response.bodyBytes)));
    throw Exception('Failed to load store data');
  }
}

class Storage_form {
  final String id;
  final String address;
  final String name;
  final String image;

  const Storage_form({
    required this.id,
    required this.address,
    required this.name,
    required this.image,
  });

  factory Storage_form.fromJson(Map<String, dynamic> json) {
    return Storage_form(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ??
          Image.asset(
            'assets/images/sample1.png',
            scale: 6,
          ),
    );
  }
}

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  bool _isEditing = false; // 편집 모드를 관리하는 변수
  late Future<List<Storage_form>> futureStorage;

  @override
  void initState() {
    super.initState();
    futureStorage = fetchStorage();
  }

  Future<void> _handleDelete(String id) async {
    bool success = await deleteStorage(id);
    if (success) {
      // 삭제가 성공했으므로 데이터를 다시 로드하여 UI를 업데이트합니다.
      setState(() {
        futureStorage = fetchStorage();
      });
    } else {
      // 삭제 실패 시 사용자에게 알림을 표시할 수 있습니다.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이템 삭제에 실패했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/images/logo.png',
            scale: 6,
          ),
          backgroundColor: Colors.white,
          shadowColor: Colors.grey,
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
            preferredSize: const Size.fromHeight(2.0),
            child: Divider(
              height: 0.8,
              color: Colors.grey.withOpacity(0.5),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              height: 600,
              child: FutureBuilder<List<Storage_form>>(
                future: futureStorage,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Container(
                        width: 50.0,
                        height: 50.0,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          strokeWidth: 6.0,
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Text(
                            '데이터가 존재하지 않습니다. 잠시 후 시도해주십시오!', //${snapshot.error}',
                            style: TextStyle(
                                fontFamily: "bm",
                                fontSize: 20,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return const Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: Text(
                              '데이터가 존재하지 않습니다. 잠시 후 시도해주십시오?',
                              style: TextStyle(
                                  fontFamily: "bm",
                                  fontSize: 20,
                                  color: Colors.grey),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return ListView(
                        padding: const EdgeInsets.all(8),
                        children: snapshot.data!.map((storageData) {
                          return storage(
                            context,
                            storageData.id,
                            storageData.name,
                            storageData.address,
                            storageData.image,
                            _isEditing,
                            _handleDelete,
                          );
                        }).toList(),
                      );
                    }
                  } else {
                    return const Center(
                      child: Text(
                        '데이터가 존재하지 않습니다. 잠시 후 시도해주십시오-사실 에러',
                        style: TextStyle(
                            fontFamily: "bm", fontSize: 20, color: Colors.grey),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ));
  }
}

Container storage(
  context,
  String id,
  String rootname,
  String address,
  image,
  bool isEditing,
  Future<void> Function(String) handleDelete,
) {
  return Container(
    child: Stack(
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StorageView(
                              id: id,
                            )));
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
                    //network로 교체할 것
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
                rootname,
                style: const TextStyle(
                  fontFamily: "Hanbit",
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
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
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                // 아이템 삭제 로직 호출
                handleDelete(id);
              },
            ),
          ),
      ],
    ),
  );
}
