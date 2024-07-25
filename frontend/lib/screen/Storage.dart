import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:frontend/components/server.dart';
import 'package:frontend/screen/StorageView.dart';
import 'package:http/http.dart' as http;

Future<List<Storage_form>> fetchStorage() async {
  var headers = {
    'Authorization': 'Bearer Usertoken', //수정할 것
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final response = await http.get(
    Uri.parse(serverUrl + '/routes'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    Iterable storeList =
        jsonDecode(utf8.decode(response.bodyBytes)); //한국어 깨지는 걸 방지하기 위함
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
  final String uid;
  final String name;
  final DateTime creacted_date;
  final DateTime updated_date;
  final image;
  final List waypoints;

  const Storage_form({
    required this.id,
    required this.uid,
    required this.name,
    required this.creacted_date,
    required this.updated_date,
    required this.waypoints,
    required this.image,
  });

  factory Storage_form.fromJson(dynamic json) {
    return Storage_form(
      id: json['price'],
      uid: json['uid'],
      name: json['name'],
      creacted_date: json['creacted_date'],
      updated_date: json['updated_date'],
      image: json['image'],
      waypoints: json['waypoints'],
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
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Center(
                        child: Text(
                          '데이터가 존재하지 않습니다. 잠시 후 시도해주십시오',
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
                    return Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Text(
                            '데이터가 존재하지 않습니다. 잠시 후 시도해주십시오',
                            style: TextStyle(
                                fontFamily: "bm",
                                fontSize: 20,
                                color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.all(20),
                      height: 195,
                      child: CustomScrollView(
                        slivers: <Widget>[
                          SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int idx) {
                                final Storage = snapshot.data![idx];
                                return storage(
                                    context,
                                    Storage.id,
                                    Storage.name,
                                    Storage.waypoints[0]["address"],
                                    _isEditing);
                              },
                              childCount: snapshot.data!.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 2 / 3,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: Text(
                      '데이터가 존재하지 않습니다. 잠시 후 시도해주십시오',
                      style: TextStyle(
                          fontFamily: "bm", fontSize: 20, color: Colors.grey),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

Container storage(
    context, String id, String rootname, String address, bool isEditing) {
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
                        builder: (context) => const StorageView()));
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
                rootname,
                style: TextStyle(
                  fontFamily: "Hanbit",
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
              Text(
                address,
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
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                // 아이템 삭제 로직 추가
              },
            ),
          ),
      ],
    ),
  );
}
