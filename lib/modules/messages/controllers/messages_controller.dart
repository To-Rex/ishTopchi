import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/models/chat_rooms.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';

class MessagesController extends GetxController {
  final Rx<ChatRooms?> chatRoomsModel = Rx<ChatRooms?>(null);
  final isLoading = false.obs;

  final ApiController apiController = Get.put(ApiController());
  final FuncController funcController = Get.put(FuncController());

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      chatRoomsModel.value = await apiController.fetchChatRooms();
    } catch (e) {
      debugPrint('fetchMessages xatolik: $e');
      // No fallback, just show empty
    } finally {
      isLoading.value = false;
    }
  }
}
