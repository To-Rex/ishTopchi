import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/models/user_me.dart';

class ProfileController extends GetxController {
  final userMe = Rxn<UserMe>();

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() async {
    final api = ApiController();
    final result = await api.getMe();
    if (result != null) {
      userMe.value = result;
    }
  }

  void launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      //await launchUrl(uri, mode: LaunchMode.externalApplication);

    } else {
      Get.snackbar('Xatolik', 'Havola ochilmadi');
    }
  }

  void onEditProfile() {
    // Profilni tahrirlash sahifasiga yo‘naltirish
    Get.snackbar('Tahrirlash', 'Tahrirlash tugmasi bosildi');
  }

  void onMyPostsTap() => Get.snackbar('E’lonlarim', 'Mening e’lonlarim sahifasi');
  void onLanguagesTap() => Get.snackbar('Tillar', 'Tillar sozlamalari ochildi');
  void onSupportTap() => Get.snackbar('Qo‘llab-quvvatlash', 'Yordamga murojaat qilindi');
  void onAboutAppTap() => Get.snackbar('Ilova haqida', 'Bu ilova haqida ma’lumot');
  void onPrivacyTap() => Get.snackbar('Maxfiylik', 'Maxfiylik siyosati');
  void onNotificationsTap() => Get.snackbar('Bildirishnomalar', 'Bildirishnoma sozlamalari');
  void onHelpTap() => Get.snackbar('Yordam', 'Yordam markazi');

  void onLogoutTap() {
    FuncController().deleteToken();
    Get.dialog(AlertDialog(
      title: const Text('Chiqish'),
      content: const Text('Rostdan ham chiqmoqchimisiz?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Yo‘q')),
        TextButton(
          onPressed: () {
            Get.back(); // Dialog yopiladi
            // Logout funksiyasi shu yerda yoziladi
            Get.offAllNamed('/login');
          },
          child: const Text('Ha'),
        ),
      ],
    ));
  }
}