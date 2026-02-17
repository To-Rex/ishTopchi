import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ishtopchi/modules/profile/views/my_posts_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/bottom_sheets.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../views/about_app_screen.dart';
import '../views/devices_screen.dart';
import '../views/edit_profile_screen.dart';
import '../views/help_center_screen.dart';
import '../views/my_profile_screen.dart';
import '../views/my_resumes_screen.dart';
import '../views/privacy_screen.dart';
import '../views/support_screen.dart';
import '../../../core/services/show_toast.dart';

class ProfileController extends GetxController {
  final appVersion = '1.0.4';
  final hasToken = false.obs;
  final RxBool isLoadingUser = false.obs;
  final RxBool isLoadingRegions = false.obs;
  final RxBool isLoadingDistricts = false.obs;
  final RxBool isUpdatingProfile = false.obs;
  final RxList<Map<String, dynamic>> regions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> districts = <Map<String, dynamic>>[].obs;
  final RxString selectedRegionId = ''.obs;
  final RxString selectedDistrictId = '0'.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString selectedGender = ''.obs;

  final FuncController funcController = Get.find<FuncController>();

  @override
  void onInit() {
    super.onInit();
    _checkTokenAndLoadUser();
    loadRegions();
    ever(funcController.globalToken, (_) => _checkTokenAndLoadUser());
    ever(selectedRegionId, (regionId) {
      if (regionId.isNotEmpty && regionId != '0') {
        loadDistricts(int.parse(regionId));
      } else {
        districts.clear();
        selectedDistrictId.value = '0';
      }
    });
  }

  void launchExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Xatolik', 'Havola ochilmadi');
    }
  }

  void onLoginTap() => Get.offNamed('/login');

  Future<void> _checkTokenAndLoadUser() async {
    final token = funcController.getToken();
    hasToken.value = token != null && token.isNotEmpty;

    if (hasToken.value && !isLoadingUser.value) {
      await loadUser();
    }
  }

  Future<void> loadUser() async {
    if (isLoadingUser.value) return;
    isLoadingUser.value = true;
    try {
      final user = funcController.userMe.value;
      funcController.setUserMe(user);
      if (user.data != null &&
          user.data!.district != null &&
          user.data!.district!.region != null) {
        selectedRegionId.value = user.data!.district!.region!.id.toString();
        selectedDistrictId.value = user.data!.district!.id.toString();
        selectedGender.value = user.data!.gender == 'MALE' ? '1' : '2';
      } else {
        selectedGender.value = '1';
      }
    } catch (e) {
      print('loadUser xatolik: $e');
      ShowToast.show('Xatolik', 'Foydalanuvchi ma’lumotlari yuklanmadi', 2, 1);
    } finally {
      isLoadingUser.value = false;
    }
  }

  Future<void> loadRegions() async {
    try {
      isLoadingRegions.value = true;
      final fetchedRegions = await ApiController().fetchRegions();
      regions.value = fetchedRegions;
      if (fetchedRegions.isNotEmpty && selectedRegionId.value.isEmpty) {
        selectedRegionId.value = fetchedRegions.first['id'].toString();
      }
    } catch (e) {
      print('loadRegions xatolik: $e');
      ShowToast.show('Xatolik', 'Viloyatlarni yuklashda xato yuz berdi', 2, 1);
    } finally {
      isLoadingRegions.value = false;
    }
  }

  Future<void> loadDistricts(int regionId) async {
    try {
      isLoadingDistricts.value = true;
      districts.clear();
      selectedDistrictId.value = '0';
      final fetchedDistricts = await ApiController().fetchDistricts(regionId);
      districts.value = fetchedDistricts;
      if (fetchedDistricts.isNotEmpty) {
        selectedDistrictId.value = fetchedDistricts.first['id'].toString();
      }
    } catch (e) {
      print('loadDistricts xatolik: $e');
      ShowToast.show('Xatolik', 'Tumanlarni yuklashda xato yuz berdi', 2, 1);
    } finally {
      isLoadingDistricts.value = false;
    }
  }

  void onEditProfile() => Get.to(() => EditProfileScreen());

  void onMyProfileTap() => Get.to(() => MyProfileScreen());

  void onMyResumesTap() => Get.to(() => MyResumesScreen());

  void onMyPostsTap() => Get.to(() => MyPostsScreen());

  void onLanguagesTap() => BottomSheets().showLanguageBottomSheet();

  void onSettingsTap() => Get.toNamed(AppRoutes.settings);

  void onDevicesTap() => Get.to(() => DevicesScreen());

  void onSupportTap() => Get.to(() => SupportScreen());

  void onAboutAppTap() => Get.to(() => AboutAppScreen());

  void onPrivacyTap() => Get.to(() => PrivacyScreen());

  void onHelpTap() => Get.to(() => HelpCenterScreen());

  void onLogoutTap() {
    final ThemeController themeController = Get.find<ThemeController>();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Accountdan chiqish'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            color: AppColors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Rostdan ham hisobingizdan chiqmoqchimisiz?'.tr,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              overlayColor: AppColors.textColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Bekor qilish'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await funcController.deleteToken();
              hasToken.value = false;
              Get.back();
              Get.offAllNamed('/login');
              ShowToast.show('Muvaffaqiyatli'.tr, 'Tizimdan chiqildi'.tr, 1, 1);
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.red,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Chiqish'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
