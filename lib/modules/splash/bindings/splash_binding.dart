import 'package:get/get.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
    FuncController().getLanguage();
  }
}
