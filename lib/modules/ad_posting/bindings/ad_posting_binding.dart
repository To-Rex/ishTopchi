import 'package:get/get.dart';
import '../controllers/ad_posting_controller.dart';

class AdPostingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdPostingController>(() => AdPostingController());
  }
}
