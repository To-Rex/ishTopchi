import 'package:get/get.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';

class MainController extends GetxController {
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();


  Future<void> fetchInitialPosts() async {
    if (!funcController.isLoading.value) {
      funcController.currentPage.value = 1;
      funcController.hasMore.value = true;
      funcController.posts.clear();
      await apiController.fetchPosts(search: funcController.searchQuery.value, page: 1);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Dastlabki postlarni yuklash
    fetchInitialPosts();

  }
}