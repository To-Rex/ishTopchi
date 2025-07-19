import 'dart:io';
import 'package:get/get.dart';
import '../../../controllers/api_controller.dart';
import '../../../core/services/show_toast.dart';

class RegisterController extends GetxController {
  final RxString selectedRegionId = ''.obs;
  final RxString selectedDistrictId = '0'.obs;
  final RxString selectedGender = ''.obs;
  final RxList<Map<String, dynamic>> regions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> districts = <Map<String, dynamic>>[].obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoadingRegions = false.obs;
  final RxBool isLoadingDistricts = false.obs;
  final RxBool isRegistering = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRegions();
    ever(selectedRegionId, (regionId) {
      if (regionId.isNotEmpty && regionId != '0') {
        loadDistricts(int.parse(regionId));
      } else {
        districts.clear();
        selectedDistrictId.value = '0';
      }
    });
  }

  Future<void> loadRegions() async {
    try {
      isLoadingRegions.value = true;
      final apiController = Get.find<ApiController>();
      final fetchedRegions = await apiController.fetchRegions();
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
      districts.clear(); // Oldingi tumanlarni tozalash
      selectedDistrictId.value = '0'; // Tuman ID sini reset qilish
      final apiController = Get.find<ApiController>();
      final fetchedDistricts = await apiController.fetchDistricts(regionId);
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

  Future<void> registerUser(
      String firstName,
      String lastName,
      String gender,
      String birthDate,
      String regionId,
      String districtId,
      File? imageFile) async {
    try {
      isRegistering.value = true;
      final apiController = Get.find<ApiController>();
      await apiController.completeRegistration(
        firstName: firstName,
        lastName: lastName,
        districtId: int.parse(districtId),
        birthDate: birthDate,
        gender: gender,
        image: imageFile,
      );
      ShowToast.show(
          'Muvaffaqiyat', 'Ro‘yxatdan o‘tish muvaffaqiyatli yakunlandi', 1, 1);
    } catch (e) {
      print('❌ registerUser xatolik: $e');
      ShowToast.show(
          'Xatolik', 'Ro‘yxatdan o‘tishda xatolik yuz berdi', 2, 1,
          duration: 2);
    } finally {
      isRegistering.value = false;
    }
  }
}