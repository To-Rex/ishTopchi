import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';

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
      final result = await ApiController().getMe();
      if (result != null) {
        funcController.userMe.value = result; // Foydalanuvchi ma’lumotlarini yangilash
      }
    } catch (e) {
      print('loadUser xatosi: $e');
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