import 'package:frontend/components/chat_message_type.dart';

class ChatClass {
  final ChatMessageType type;
  dynamic message;
  ChatClass({
    required this.type,
    required message,
  });

  factory ChatClass.sent({required message, required type}) =>
      ChatClass(message: message, type: type);
}
