import 'package:get/get.dart';
import '../controllers/my_posts_controller.dart';
import '../controllers/profile_controller.dart';

class MyPostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyPostsController>(() => MyPostsController());
  }
}
