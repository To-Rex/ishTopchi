import 'package:get/get.dart';
import '../../../controllers/api_controller.dart';

class MainController extends GetxController {
  final ApiController apiController = Get.find<ApiController>();

  @override
  void onInit() {
    super.onInit();
    final token = apiController.funcController.getToken();
    if (token != null) {
      apiController.getMe();
    } else {
      print('Token mavjud emas, iltimos login qiling');
    }

    apiController.fetchPosts(); // Postlarni yuklash
    apiController.fetchWishlist(); // Wishlistni yuklash
  }
}