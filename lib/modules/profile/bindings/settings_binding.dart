import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../views/settings_screen.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    // ThemeController allaqachon main.dart da Put qilingan, shuning uchun uni qayta yaratmaymiz
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }
  }
}
