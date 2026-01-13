import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../core/models/chat_rooms.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/socket_service.dart';

class MessagesController extends GetxController {
  final Rx<ChatRooms?> chatRoomsModel = Rx<ChatRooms?>(null);
  final isLoading = false.obs;

  final ApiController apiController = Get.put(ApiController());
  final FuncController funcController = Get.put(FuncController());
  final SocketService socketService = SocketService();

  bool _listenersRegistered = false;

  @override
  void onInit() {
    super.onInit();
    _setupSocketConnection();
    fetchMessages();
  }

  @override
  void onClose() {
    // Remove listeners to prevent duplicates
    if (_listenersRegistered) {
      socketService.removeNewMessageListener(_onNewMessage);
      _listenersRegistered = false;
    }
    // Update presence to offline when leaving messages screen
    socketService.updatePresence(false);
    super.onClose();
  }

  void _onNewMessage(Map<String, dynamic> data) {
    // Refresh chat rooms when a new message arrives
    fetchMessages();
  }

  void _setupSocketConnection() {
    final token = funcController.getToken();
    if (token != null && token.isNotEmpty) {
      // Connect to socket if not already connected
      if (!socketService.isConnected) {
        socketService.connect(token: token);
      }

      // Only register listeners once
      if (!_listenersRegistered) {
        // Listen for new messages to refresh chat rooms
        socketService.onNewMessage(_onNewMessage);
        _listenersRegistered = true;
      }

      // Update presence when user opens messages screen
      socketService.updatePresence(true);
    }
  }

  Future<void> fetchMessages() async {
    try {
      isLoading.value = true;
      if (funcController.getToken() == null ||
          funcController.getToken() == '') {
        isLoading.value = false;
      } else {
        chatRoomsModel.value = await apiController.fetchChatRooms();
      }
    } catch (e) {
      debugPrint('fetchMessages xatolik: $e');
      isLoading.value = false;
      // No fallback, just show empty
    } finally {
      isLoading.value = false;
    }
  }
}
