import 'package:get/get.dart';

class Message {
  final String sender;
  final String preview;
  final String time;
  final int unreadCount;

  Message({
    required this.sender,
    required this.preview,
    required this.time,
    this.unreadCount = 0,
  });
}

class ChatMessage {
  final String sender;
  final String text;
  final String time;
  final bool isMe;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.time,
    required this.isMe,
  });
}
