import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';

class OnboardingController extends GetxController {
  void completeOnboarding() {
    //Get.offNamed(AppRoutes.login);
    Get.offNamed(AppRoutes.main);
  }
}
