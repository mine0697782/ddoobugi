import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController chat_controller = TextEditingController();
  var recommend = ["주변 화장실 알려줘", "가까운 카페알려줘"];
  String InputChat = "";
  List<Widget> recommendWidget = <Widget>[];

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
          body: const SingleChildScrollView(),
          bottomNavigationBar: Row(
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
                            borderSide: BorderSide(color: Color(0xFFD9D9D9)))),
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
                    });
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Color(0xFF00C9FF),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
