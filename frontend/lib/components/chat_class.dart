import 'package:frontend/components/chat_message_type.dart';

class ChatClass {
  final ChatMessageType type;
  final String message;
  final Map data;

  ChatClass({
    required this.type,
    this.message = "다음은 해당 위치에서 갈 수 있는 곳을 추천한 결과입니다. 눌러서 세부 정보를 확인하세요",
    this.data = const {},
  });

  factory ChatClass.sent({message, required type, data}) =>
      ChatClass(message: message, type: type, data: data);
}
