import 'package:get/get.dart';
import '../../../core/models/message_model.dart';
class MessagesDetailController extends GetxController {
  final messages = <Message>[].obs;
  final filteredMessages = <Message>[].obs;
  final searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    messages.addAll([
      Message(sender: 'Ali', preview: 'Salom, qanday yaxshi?', time: '10:30', unreadCount: 2),
      Message(sender: 'Vali', preview: 'Bugun uchrashuv bormi?', time: '09:15', unreadCount: 0),
      Message(sender: 'Nodira', preview: 'Fayllarni yubordim', time: 'Yesterday', unreadCount: 1),
    ]);
    // Dastlabki holatda barcha xabarlar ko‘rsatiladi
    filteredMessages.assignAll(messages);
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
}