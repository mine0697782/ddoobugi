import 'package:flutter/material.dart';

class StorageView extends StatefulWidget {
  const StorageView({super.key});

  @override
  _StorageViewState createState() => _StorageViewState();
}

class _StorageViewState extends State<StorageView> {
  final TextEditingController _titleController =
      TextEditingController(text: '내가 가는 길');
  bool _isEditingTitle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          scale: 6,
        ),
        backgroundColor: Colors.white,
        actions: [
          _isEditingTitle
              ? IconButton(
                  icon: Icon(Icons.save, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isEditingTitle = false;
                    });
                  },
                )
              : IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    setState(() {
                      _isEditingTitle = true;
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/sample1.png',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            // 제목
            _isEditingTitle
                ? TextField(
                    controller: _titleController,
                    style: TextStyle(
                      fontFamily: "Hanbit",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    _titleController.text,
                    style: TextStyle(
                      fontFamily: "Hanbit",
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            SizedBox(height: 8),
            // 위치 정보
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  '서울 성북구 정릉로 77',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 8),
            // 시간 정보
            Row(
              children: [
                Icon(Icons.access_time, color: Colors.black),
                SizedBox(width: 8),
                Text(
                  '2024-07-22 18:00',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 16),
            // 지도 버튼
            GestureDetector(
              onTap: () {
                // 지도 버튼 클릭 시 동작
              },
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '지도',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
            ),
            Spacer(),
            // 따라가기 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  _showFollowDialog(context);
                },
                child: Text(
                  '따라가기',
                  style: TextStyle(
                      fontFamily: "Hanbit", fontSize: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFollowDialog(BuildContext context) {
    // 같을경우 이어갈지 질문
    //   showDialog(
    //     context: context,
    //     builder: (BuildContext context) {
    //       return Dialog(
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(10),
    //         ),
    //         child: Container(
    //           width: 200,
    //           child: Stack(
    //             children: [
    //               Container(
    //                 margin: EdgeInsets.all(10),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize
    //                       .min, // Ensure that the column only takes up as much space as its content
    //                   children: [
    //                     SizedBox(height: 10),
    //                     Text(
    //                       '내가 가는 길',
    //                       style: TextStyle(fontFamily: "Hanbit", fontSize: 25),
    //                     ),
    //                     SizedBox(height: 10),
    //                     Text(
    //                       '루트대로 시작할까요?',
    //                       style: TextStyle(fontFamily: "Hanbit", fontSize: 15),
    //                     ),
    //                     SizedBox(height: 20),
    //                     Row(
    //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                       children: [
    //                         Container(
    //                           width: 180,
    //                           child: TextButton(
    //                             style: TextButton.styleFrom(
    //                               backgroundColor: Colors.lightBlue,
    //                               shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(10),
    //                               ),
    //                             ),
    //                             onPressed: () {
    //                               Navigator.of(context).pop();
    //                             },
    //                             child: Text('예',
    //                                 style: TextStyle(color: Colors.white)),
    //                           ),
    //                         ),
    //                         Flexible(
    //                           fit: FlexFit.loose,
    //                           child: TextButton(
    //                             style: TextButton.styleFrom(
    //                               backgroundColor: Colors.red,
    //                               shape: RoundedRectangleBorder(
    //                                 borderRadius: BorderRadius.circular(10),
    //                               ),
    //                             ),
    //                             onPressed: () {
    //                               Navigator.of(context).pop();
    //                             },
    //                             child: Text('아니요',
    //                                 style: TextStyle(color: Colors.white)),
    //                           ),
    //                         ),
    //                       ],
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //               Positioned(
    //                 right: 0,
    //                 top: 0,
    //                 child: IconButton(
    //                   icon: Icon(Icons.close, color: Colors.black),
    //                   onPressed: () {
    //                     Navigator.of(context).pop();
    //                   },
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       );
    //     },
    //   );
    // }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: 200,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize
                        .min, // Ensure that the column only takes up as much space as its content
                    children: [
                      SizedBox(height: 10),
                      Text(
                        '국민대학교 산책 코스',
                        style: TextStyle(fontFamily: "Hanbit", fontSize: 25),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '지도',
                        style: TextStyle(fontFamily: "Hanbit", fontSize: 15),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '위치 정릉로 77',
                        style: TextStyle(fontFamily: "Hanbit", fontSize: 15),
                      ),
                      Text(
                        '설명',
                        style: TextStyle(fontFamily: "Hanbit", fontSize: 15),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      //버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
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
                              child: Text('예',
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
                              child: Text('아니요',
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
                    icon: Icon(Icons.close, color: Colors.black),
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
}
