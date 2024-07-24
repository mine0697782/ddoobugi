import 'package:flutter/material.dart';

void _showFollowCheckDialog(BuildContext context,
    {String title = "선택한 코스",
    String image = "경로",
    String address = "주소",
    String commend = "설명"}) {
  // String title='';
  // String image='';
  // String address='';
  // String commend='';
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: 200,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ensure that the column only takes up as much space as its content
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style:
                          const TextStyle(fontFamily: "Hanbit", fontSize: 25),
                    ),
                    const SizedBox(height: 10),
                    Image.asset(image),
                    const SizedBox(height: 20),
                    Text(
                      address,
                      style:
                          const TextStyle(fontFamily: "Hanbit", fontSize: 15),
                    ),
                    Text(
                      commend,
                      style:
                          const TextStyle(fontFamily: "Hanbit", fontSize: 15),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    //버튼
                    SizedBox(
                      width: 180,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('예',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showFollowStartDialog(BuildContext context) {
  //같을경우 이어갈지 질문
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: SizedBox(
          width: 200,
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Ensure that the column only takes up as much space as its content
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      '내가 가는 길',
                      style: TextStyle(fontFamily: "Hanbit", fontSize: 25),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '루트대로 시작할까요?',
                      style: TextStyle(fontFamily: "Hanbit", fontSize: 15),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 180,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('예',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('아니요',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
