import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/components/User.dart';
import 'package:frontend/components/app_theme.dart';
import 'package:frontend/components/chat_class.dart';
import 'package:frontend/components/chat_message_type.dart';
import 'package:frontend/components/server.dart';
import 'package:http/http.dart' as http;

class Chat extends StatefulWidget {
  User? userdata;
  Chat({
    this.userdata,
    super.key,
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController chat_controller = TextEditingController();
  final scrollController = ScrollController();
  List<ChatClass> CHAT = [];
  late List CHAT_hard;
  late User userdata;

  @override
  void initState() {
    super.initState();
    userdata = widget.userdata!;
    print(
        "CHAT: ${userdata.lat}, ${userdata.lot}---------------------------------------------------------------");
  }

  Future<void> sendData(BuildContext context, Map<String, String> send) async {
    var url = "$serverUrl/chat/select";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'authorization': 'Bearer ${userdata.Usertoken}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(send));
  }

  Future<void> onFieldSubmitted(
      BuildContext context, Map<String, dynamic> chatting) async {
    var url = "$serverUrl/chat/search";
    print(userdata.Usertoken);
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'authorization': 'Bearer ${userdata.Usertoken}',
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(chatting));

    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    try {
      print("시도중~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      print("${userdata.lat}    ${userdata.lot}");
      if (response.statusCode == 200) {
        print("받아오기 성공");
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        print(responseData["places"]);
        print(response.body);

        List<dynamic> placesList = responseData["places"];

        List<Map<String, dynamic>> places = placesList
            .whereType<Map<String, dynamic>>()
            .map((item) => item)
            .toList();
        // ChatClass newC =
        //     ChatClass(type: ChatMessageType.received, data: places[0]);
        // print(newC.data);
        print(places[0]['이름']);
        print(places);
        print(places[0]["place_id"]);
        setState(() {
          CHAT_hard = places;
          ChatClass newC =
              ChatClass(data: places[0], type: ChatMessageType.received);
          CHAT.add(newC);
        });

        // setState(() {
        //   // 기존의 ChatClass를 추가하는 부분
        //   ChatClass newC =
        //       ChatClass(data: places[0], type: ChatMessageType.received);
        //   CHAT.add(newC);
        //   ChatClass newd =
        //       ChatClass(data: places[1], type: ChatMessageType.received);
        //   CHAT.add(newd);
        //   // ChatClass newe =
        //   //     ChatClass(data: places[2], type: ChatMessageType.received);
        //   // CHAT.add(newe);
        //   userdata.rid = responseData["rid"];
        // });
      } else {
        print(
            "받아오기 실패~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
      }
    } catch (e) {
      print("오류 발생: $e");
      rethrow;
    }
  }

  var recommend = [
    "다음 웨이포인트 이어가기",
    "주변 화장실 알려줘",
    "가까운 카페알려줘",
    "공원 찾아줘",
    "가까운 편의점 경로 알려줘"
  ];

  void _sendMessage(String chat) {
    if (chat.isNotEmpty) {
      setState(() {
        ChatClass text = ChatClass(message: chat, type: ChatMessageType.sent);
        CHAT.add(text);
        chat_controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                //reverse: true,
                itemCount: CHAT.length,
                itemBuilder: (context, index) {
                  ChatClass currentChat = CHAT[index];
                  if (currentChat.type == ChatMessageType.sent) {
                    return Container(
                      height: size.height * 0.05,
                      width: size.width * 0.4,
                      padding: const EdgeInsets.all(10),
                      margin: EdgeInsets.only(left: size.width * 0.5),
                      decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currentChat.message,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                    );
                  } else if (CHAT_hard.isNotEmpty) {
                    print("tlqktlqk");
                    /////////////////////////////////////
                    // List<Map<String, dynamic>> places =
                    //     currentChat.data["places"];
                    return Container(
                      height: size.height * 0.5,
                      width: size.width * 0.3,
                      margin: EdgeInsets.only(right: size.width * 0.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 5,
                          ),
                          const Text(
                            "다음은 해당 위치에서 갈 수 있는 곳을 추천한 결과입니다. 눌러서 세부 정보를 확인하세요",
                            style: TextStyle(color: Colors.black),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: CHAT_hard.length,
                              itemBuilder: (context, index_) {
                                print("실행");
                                double fontSize = 10;
                                Map<String, dynamic> currentPlace =
                                    CHAT_hard[index_]; //null로 들어가고있음
                                return GestureDetector(
                                  onTap: () {
                                    Map<String, String> request = {
                                      "chat": chat_controller.text,
                                      "rid": "",
                                      "place_id": currentPlace["place_id"],
                                    };
                                    sendData(context, request);
                                  },
                                  child: Container(
                                      width: size.width * 0.5,
                                      //height: size.height * 0.35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(children: [
                                        Text(currentPlace["이름"],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: fontSize + 5)),
                                        Text("점수: ${currentPlace["평점"]}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: fontSize)),
                                        Text("거리: ${currentPlace["거리"]}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: fontSize)),
                                        Text("주소: ${currentPlace["주소"]}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: fontSize)),
                                        Text("이유: ${currentPlace["이유"]}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: fontSize)),
                                        Text("요약: ${currentPlace["리뷰요약"]}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: fontSize))
                                      ])),
                                );
                              })
                        ],
                      ),
                    );
                  }
                  return null;
                },
                controller: scrollController,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Chat_auto(size),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: size.width * 0.8,
                        height: size.height * 0.05,
                        child: TextField(
                          controller: chat_controller,
                          decoration: const InputDecoration(
                              hintText: "메세지를 입력하세요...",
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFD9D9D9),
                                ),
                              ),
                              focusColor: Color(0xFFD9D9D9),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFD9D9D9)))),
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          //chatting
                          Map<String, dynamic> chatting = {
                            "chat": chat_controller.text,
                            "lat": userdata.lat,
                            "lon": userdata.lot,
                            "rid": "",
                            "address": ""
                          };
                          setState(() {
                            _sendMessage(chat_controller.text);
                          });
                          onFieldSubmitted(context, chatting);
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFF00C9FF),
                        ))
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container Chat_auto(Size size) {
    return Container(
      height: 50,
      width: size.width * 1,
      margin: const EdgeInsets.only(left: 5, right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recommend.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 50,
            child: TextButton(
              onPressed: () {
                setState(() {
                  chat_controller.text = recommend[index];
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFD9D9D9),
                //fixedSize:
              ),
              child: Text(
                recommend[index],
                style: const TextStyle(color: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}
