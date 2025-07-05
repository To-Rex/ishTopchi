import 'package:get/get.dart';
import '../../../core/models/message_model.dart';


class MessagesController extends GetxController {
  final messages = <Message>[].obs;
  final filteredMessages = <Message>[].obs;
  final searchQuery = ''.obs;
  final Map<String, RxList<ChatMessage>> chatMessages = {};

  @override
  void onInit() {
    super.onInit();
    messages.addAll([
      Message(sender: 'Ali', preview: 'Salom, qanday yaxshi?', time: '10:30', unreadCount: 2),
      Message(sender: 'Vali', preview: 'Bugun uchrashuv bormi?', time: '09:15', unreadCount: 0),
      Message(sender: 'Nodira', preview: 'Fayllarni yubordim', time: 'Yesterday', unreadCount: 1),
    ]);
    filteredMessages.assignAll(messages);

    // Har bir sender uchun dastlabki chat xabarlarini tayyorlash
    for (var message in messages) {
      chatMessages[message.sender] = <ChatMessage>[].obs;
      chatMessages[message.sender]!.addAll([
        ChatMessage(
          sender: message.sender,
          text: message.preview,
          time: message.time,
          isMe: false,
        ),
        ChatMessage(
          sender: 'Siz',
          text: 'Javob namunasi: Yaxshi, rahmat!',
          time: _currentTime(),
          isMe: true,
        ),
      ]);
    }
  }

  void filterMessages(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredMessages.assignAll(messages);
    } else {
      filteredMessages.assignAll(
        messages.where((message) =>
        message.sender.toLowerCase().contains(query.toLowerCase()) ||
            message.preview.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }

  void sendMessage(String sender, String text) {
    if (text.isNotEmpty) {
      chatMessages[sender]!.add(
        ChatMessage(
          sender: 'Siz',
          text: text,
          time: _currentTime(),
          isMe: true,
        ),
      );
      // Suhbatdoshdan avtomatik javob (namuna sifatida)
      Future.delayed(Duration(seconds: 1), () {
        chatMessages[sender]!.add(
          ChatMessage(
            sender: sender,
            text: 'Javob: $text ga rahmat!',
            time: _currentTime(),
            isMe: false,
          ),
        );
      });
    }
  }

  String _currentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}