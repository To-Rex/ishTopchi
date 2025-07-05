import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';

class AdPostingController extends GetxController {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final salaryFromController = TextEditingController();
  final salaryToController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final isOpen = true.obs;
  final selectedCategory = 1.obs;
  final locationTitleController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();
  final selectedImage = Rx<File?>(null);
  final regions = <Map<String, dynamic>>[].obs;
  final districts = <Map<String, dynamic>>[].obs;
  final selectedRegionId = ''.obs;
  final selectedDistrictId = '0'.obs;
  final isLoadingDistricts = false.obs;

  final ImagePicker _picker = ImagePicker();
  final ApiController apiController = Get.find<ApiController>();

  // Kategoriya ro'yxati (namuna sifatida)
  final categories = ['IT', 'Marketing', 'Ta\'lim', 'Sotuv'].obs;

  @override
  void onInit() {
    super.onInit();
    loadRegions();
  }

  Future<void> loadRegions() async {
    final fetchedRegions = await apiController.fetchRegions();
    if (fetchedRegions.isNotEmpty) {
      regions.value = fetchedRegions;
      selectedRegionId.value = fetchedRegions.first['id'].toString();
      await loadDistricts(int.parse(selectedRegionId.value));
    }
  }

  Future<void> loadDistricts(int regionId) async {
    isLoadingDistricts.value = true;
    final fetchedDistricts = await apiController.fetchDistricts(regionId);
    districts.value = fetchedDistricts;
    isLoadingDistricts.value = false;
    if (fetchedDistricts.isNotEmpty) {
      selectedDistrictId.value = fetchedDistricts.first['id'].toString();
    } else {
      selectedDistrictId.value = '0';
    }
  }

  void pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  bool validateForm() {
    return titleController.text.isNotEmpty &&
        contentController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        selectedRegionId.value.isNotEmpty &&
        selectedDistrictId.value != '0';
  }

  void submitAd() {
    if (validateForm()) {
      // Ma'lumotlarni serverga yuborish logikasi keyinchalik qo'shiladi
      Get.snackbar(
        'Muvaffaqiyat',
        'E\'lon yuborildi! Status: PENDING',
        backgroundColor: AppColors.midBlue,
        colorText: AppColors.lightGray,
      );
      // Formani tozalash
      titleController.clear();
      contentController.clear();
      salaryFromController.clear();
      salaryToController.clear();
      phoneNumberController.clear();
      emailController.clear();
      locationTitleController.clear();
      latitudeController.clear();
      longitudeController.clear();
      selectedImage.value = null;
      selectedRegionId.value = regions.isNotEmpty ? regions.first['id'].toString() : '';
      selectedDistrictId.value = '0';
    } else {
      Get.snackbar(
        'Xato',
        'Iltimos, majburiy maydonlarni to\'ldiring (sarlavha, tavsif, telefon, viloyat, tuman)!',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    salaryFromController.dispose();
    salaryToController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    locationTitleController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }
}