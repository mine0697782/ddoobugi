import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController chat_controller = TextEditingController();
  var recommend = [
    "다음 웨이포인트 이어가기",
    "주변 화장실 알려줘",
    "가까운 카페알려줘",
    "공원 찾아줘",
    "가까운 편의점 경로 알려줘"
  ];
  String InputChat = "";

  void _sendMessage() {
    if (chat_controller.text.isNotEmpty) {
      //정보 보내기
      chat_controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            shape: const Border(
                bottom: BorderSide(
              color: Color(0xFFD9D9D9),
              width: 1,
            )),
            title: const Text(
              "뚜벅이",
              style: TextStyle(
                fontFamily: "Hanbit",
                fontSize: 20,
              ),
            )),
        resizeToAvoidBottomInset: true,
        body: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Container(
              child: const Column(
                children: <Widget>[
                  //채팅창 구현
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
                        setState(() {
                          InputChat = chat_controller.text;
                          _sendMessage();
                        });
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
                  InputChat = recommend[index];
                  chat_controller.text = InputChat;
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
