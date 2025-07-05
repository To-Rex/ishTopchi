import 'package:get/get.dart';
import '../controllers/messages_detail_controller.dart';

class MessagesDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagesDetailController>(() => MessagesDetailController());
  }
}