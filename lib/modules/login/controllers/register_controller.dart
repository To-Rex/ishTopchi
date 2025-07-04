import 'dart:io';
import 'package:get/get.dart';
import '../../../controllers/api_controller.dart';
import '../../../core/services/show_toast.dart';

class RegisterController extends GetxController {
  final RxString selectedRegionId = ''.obs;
  final RxString selectedDistrictId = '0'.obs;
  final RxString selectedGender = ''.obs;
  final RxList<Map<String, dynamic>> districts = <Map<String, dynamic>>[].obs;
  final Rx<File?> selectedImage = Rx<File?>(null); // Surat uchun observable

  final RxBool isLoading = false.obs;

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

  Future<void> registerUser(String firstName, String lastName, String gender, String birthDate, String regionId, String districtId, File? imageFile) async {
    print('✅ Ro‘yxatdan o‘tish ma’lumotlari: $gender');
    try {
      isLoading.value = true;
      // print('✅ Ro‘yxatdan o‘tish ma’lumotlari:');
      // print('Ism: $firstName');
      // print('Familiya: $lastName');
      // print('Jins: $gender');
      // print('Tug‘ilgan sana: $birthDate');
      // print('Viloyat ID: $regionId');
      // print('Tuman ID: $districtId');
      // print('Surat fayl: ${imageFile?.path ?? "Tanlanmagan"}');
      ShowToast.show('Muvaffaqiyat', 'Ro‘yxatdan o‘tish muvaffaqiyatli yakunlandi', 1, 1);
      ApiController apiController = Get.find<ApiController>();
      await apiController.completeRegistration(firstName: firstName, lastName: lastName, districtId: int.parse(districtId), birthDate: birthDate, gender: gender.toString(), image: imageFile
      );
    } catch (e) {
      print('❌ registerUser xatolik: $e');
      ShowToast.show('Xatolik', 'Ro‘yxatdan o‘tishda xatolik yuz berdi', 2, 1, duration: 2);
    } finally {
      isLoading.value = false;
    }
  }
}