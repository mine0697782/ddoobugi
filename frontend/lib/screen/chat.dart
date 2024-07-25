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

  late User userdata;

  @override
  void initState() {
    super.initState();
    userdata = widget.userdata!;
  }

  Future<void> sendData(BuildContext context, Map<String, String> send) async {
    var url = "$serverUrl/chat/select";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(send));
  }

  Future<void> onFieldSubmitted(
      BuildContext context, Map<String, dynamic> chatting) async {
    _sendMessage();
    var url = "$serverUrl/chat/search";
    final response = await http.post(Uri.parse(url),
        headers: <String, String>{},
        body: jsonEncode(chatting)); //string으로 위도 경도가 자동으로 바뀌나?? 오류나면 확인
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));

        CHAT = [
          ...CHAT,
          ChatClass.sent(message: responseData, type: ChatMessageType.received)
        ];
      }
    } catch (e) {
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

  void _sendMessage() {
    if (chat_controller.text.isNotEmpty) {
      CHAT = [
        ...CHAT,
        ChatClass.sent(
            message: chat_controller.text, type: ChatMessageType.sent)
      ];
      chat_controller.clear();
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
        body: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  if (CHAT.isNotEmpty)
                    Align(
                        alignment: Alignment.topCenter,
                        child: ListView.builder(
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: CHAT.length,
                          itemBuilder: (context, index) {
                            ChatClass currentChat = CHAT[index];
                            List<Map<String, dynamic>> places =
                                currentChat.message["places"];
                            if (currentChat.type == ChatMessageType.sent) {
                              return Container(
                                height: size.height * 0.8,
                                width: size.width * 0.6,
                                decoration: const BoxDecoration(
                                    color: Color.fromARGB(255, 61, 24, 24)),
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
                            } else if (currentChat.type ==
                                ChatMessageType.received) {
                              return Container(
                                height: size.height * 0.5,
                                width: size.width * 0.6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "다음은 해당 위치에서 갈 수 있는 곳을 추천한 결과입니다.눌러서 세부 정보를 확인하세요",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: currentChat
                                            .message["places"].lenght,
                                        itemBuilder: (context, index_) {
                                          setState(() {});
                                          double fontSize = 10;
                                          Map<String, dynamic> currentPlace =
                                              places[index_];
                                          return GestureDetector(
                                            onTap: () {
                                              Map<String, String> request = {
                                                "token": userdata.Usertoken,
                                                "chat": chat_controller.text,
                                                "rid": "",
                                                "place_id":
                                                    currentPlace["place_id"],
                                              };
                                              sendData(context, request);
                                            },
                                            child: Container(
                                                width: size.width * 0.5,
                                                height: size.height * 0.35,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(children: [
                                                  Text(
                                                      currentPlace[
                                                          "place_name"],
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize:
                                                              fontSize + 5)),
                                                  Text(
                                                      "점수: ${currentPlace["score"]}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: fontSize)),
                                                  Text(
                                                      "거리: ${currentPlace["distance"]}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: fontSize)),
                                                  Text(
                                                      "주소: ${currentPlace["address"]}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: fontSize)),
                                                  Text(
                                                      "이유: ${currentPlace["reason"]}",
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: fontSize)),
                                                  Text(
                                                      "요약: ${currentPlace["summary"]}",
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
                        ))
                ],
              ),
            ),
          ),
          bottomNavigationBar: Column(
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
                          "token": userdata.Usertoken,
                          "chat": chat_controller.text,
                          "lat": userdata.lat,
                          "lon": userdata.lot,
                          "rid": "",
                          "address": ""
                        };
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
