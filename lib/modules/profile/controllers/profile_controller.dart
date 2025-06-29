import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/bottom_sheets.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../views/about_app_screen.dart';
import '../views/edit_profile_screen.dart';
import '../views/help_center_screen.dart';
import '../views/my_resumes_screen.dart';
import '../views/notifications_screen.dart';
import '../views/privacy_screen.dart';
import '../views/support_screen.dart';

class ProfileController extends GetxController {
  final hasToken = false.obs;
  final RxBool _isLoadingUser = false.obs; // Yuklash holatini kuzatish

  final FuncController funcController = Get.find<FuncController>();

  @override
  void onInit() {
    super.onInit();
    _checkTokenAndLoadUser();
  }

  Future<void> _checkTokenAndLoadUser() async {
    final token = funcController.getToken();
    hasToken.value = token != null && token.isNotEmpty;

    if (hasToken.value && !_isLoadingUser.value) {
      await loadUser();
    }
  }

  Future<void> loadUser() async {
    if (_isLoadingUser.value) return; // Agar yuklanayotgan bo‘lsa, to‘xtatish
    _isLoadingUser.value = true;
    try {
      ApiController().getMe();
    } catch (e) {
      _isLoadingUser.value = false;
    } finally {
      _isLoadingUser.value = false;
    }
  }

  void launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // launchUrl(uri, mode: LaunchMode.externalApplication); // hozircha o‘chirib qo‘yilgan
    } else {
      Get.snackbar('Xatolik', 'Havola ochilmadi');
    }
  }

  void onLoginTap() {
    Get.toNamed('/login');
  }


  void onEditProfile() {
    Get.to(() => EditProfileScreen()); // Yangi ekran ochish
  }
  //MyResumesScreen
  void onMyResumesTap() => Get.to(() => MyResumesScreen());
  void onMyPostsTap() => Get.snackbar('Mening e’lonlarim', 'Mening e’lonlarim sozlamalari ochildi');
  void onLanguagesTap() => BottomSheets().showLanguageBottomSheet();
  void onSupportTap() => Get.to(() => SupportScreen());
  void onAboutAppTap() => Get.to(() => AboutAppScreen());
  void onPrivacyTap() => Get.to(() => PrivacyScreen());
  void onNotificationsTap() => Get.to(() => NotificationsScreen());
  void onHelpTap() => Get.to(() => HelpCenterScreen());

  void onLogoutTap() {
    Get.dialog(AlertDialog(
      title: const Text('Chiqish'),
      content: const Text('Rostdan ham chiqmoqchimisiz?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Yo‘q')),
        TextButton(
          onPressed: () async {
            await funcController.deleteToken();
            hasToken.value = false;
            funcController.userMe.value = null;
            Get.back();
            Get.offAllNamed('/login');
          },
          child: const Text('Ha'),
        ),
      ],
    ));
  }
}