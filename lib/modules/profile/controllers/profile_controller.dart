import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ishtopchi/modules/profile/views/my_posts_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/bottom_sheets.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../views/about_app_screen.dart';
import '../views/edit_profile_screen.dart';
import '../views/help_center_screen.dart';
import '../views/my_profile_screen.dart';
import '../views/my_resumes_screen.dart';
import '../views/notifications_screen.dart';
import '../views/privacy_screen.dart';
import '../views/support_screen.dart';

class ProfileController extends GetxController {
  final hasToken = false.obs;
  final RxBool _isLoadingUser = false.obs; // Yuklash holatini kuzatish
  var regions = <Map<String, dynamic>>[].obs;
  var districts = <Map<String, dynamic>>[].obs;
  var selectedRegionId = ''.obs;
  var selectedDistrictId = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null); // Surat uchun observable
  final RxString selectedGender = ''.obs;

  final FuncController funcController = Get.find<FuncController>();

  @override
  void onInit() {
    super.onInit();
    _checkTokenAndLoadUser();
    loadRegions();
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
      final user = await ApiController().getMe();
      if (user != null) {
        funcController.setUserMe(user);
        if (user.data != null && user.data!.district != null && user.data!.district!.region != null) {
          selectedRegionId.value = user.data!.district!.region!.id.toString();
          selectedDistrictId.value = user.data!.district!.id.toString();
          selectedGender.value = user.data!.gender == 'MALE' ? '1' : '2';
        } else {
          selectedRegionId.value = regions.isNotEmpty ? regions.first['id'].toString() : '';
          selectedDistrictId.value = '0';
          selectedGender.value = '1'; // Default qiymat
        }
      }
    } catch (e) {
      _isLoadingUser.value = false;
      print('loadUser xatolik: $e');
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

  void onLoginTap() => Get.toNamed('/login');

  Future<void> loadRegions() async {
    final fetchedRegions = await ApiController().fetchRegions();
    if (fetchedRegions.isNotEmpty) {
      regions.value = fetchedRegions;
      if (selectedRegionId.value.isEmpty) {
        selectedRegionId.value = fetchedRegions.first['id'].toString();
        await loadDistricts(int.parse(selectedRegionId.value));
      }
    }
  }

  Future<void> loadDistricts(int regionId) async {
    final fetchedDistricts = await ApiController().fetchDistricts(regionId);
    districts.value = fetchedDistricts;
    if (fetchedDistricts.isNotEmpty && selectedDistrictId.value == '0') {
      selectedDistrictId.value = fetchedDistricts.first['id'].toString();
    }
  }

  void onEditProfile() => Get.to(() => EditProfileScreen());

  void onMyProfileTap() => Get.to(() => MyProfileScreen());
  void onMyResumesTap() => Get.to(() => MyResumesScreen());
  //void onMyPostsTap() => Get.toNamed('/my_posts');
  void onMyPostsTap() => Get.to(() => MyPostsScreen());
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