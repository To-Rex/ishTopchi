import 'dart:io';
import 'package:get/get.dart';
import '../../../controllers/api_controller.dart';

class RegisterController extends GetxController {
  final RxString selectedRegionId = ''.obs;
  final RxString selectedDistrictId = '0'.obs;
  final RxString selectedGender = ''.obs;
  final RxList<Map<String, dynamic>> districts = <Map<String, dynamic>>[].obs;
  final Rx<File?> selectedImage = Rx<File?>(null); // Surat uchun observable

  @override
  void onInit() {
    super.onInit();
    // Viloyat tanlanganidan so'ng avtomatik tumanlarni yuklash uchun
    ever(selectedRegionId, (regionId) {
      if (regionId.isNotEmpty) {
        loadDistricts(int.parse(regionId));
      }
    });
  }

  Future<void> loadDistricts(int regionId) async {
    try {
      final apiController = Get.find<ApiController>();
      final fetchedDistricts = await apiController.fetchDistricts(regionId);
      districts.value = fetchedDistricts;
      if (fetchedDistricts.isNotEmpty && selectedDistrictId.value == '0') {
        selectedDistrictId.value = fetchedDistricts.first['id'].toString(); // Birinchi tuman tanlanadi
      }
    } catch (e) {
      print('loadDistricts xatolik: $e');
      districts.value = [];
    }
  }
}