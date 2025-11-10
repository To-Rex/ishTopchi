import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;
import '../core/models/devices_model.dart';
import '../core/models/me_post_model.dart';
import '../core/models/me_stats.dart';
import '../core/models/post_model.dart';
import '../core/models/resumes_model.dart';
import '../core/models/user_me.dart' hide Data;
import '../core/models/wish_list.dart';
import '../core/services/show_toast.dart';
import 'api_controller.dart';

class FuncController {
  final GetStorage storage = GetStorage();

  final barIndex = 0.obs;
  final RxString globalToken = ''.obs;
  final RxString otpToken = ''.obs;
  final RxString otpPhone = ''.obs;
  final RxList<Data> posts = <Data>[].obs;
  final RxList<MeData> mePosts = <MeData>[].obs;
  final RxList<WishList> wishList = <WishList>[].obs;
  var meStats = MeStats().obs;
  var devicesModel = DevicesModel().obs;
  final resumes = <ResumesData>[].obs; // Resumelarni saqlash uchun
  final totalResumes = 0.obs; // Umumiy resumelar soni
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalPosts = 0.obs;
  final RxInt totalMePosts = 0.obs;
  final userMe = UserMe().obs;

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  final RxString deviceName = ''.obs;
  final RxString deviceModel = ''.obs;
  final RxString deviceId = ''.obs;
  final RxString platform = ''.obs;
  final RxBool hasToken = false.obs;



  final RxList<Map<String, dynamic>> regions = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> districts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxnInt selectedRegion = RxnInt(); // null boshlang‘ich qiymat
  final RxnInt selectedDistrict = RxnInt(); // null boshlang‘ich qiymat
  final RxnInt selectedCategory = RxnInt(); // null boshlang‘ich qiymat
  final RxnString jobType = RxnString(); // null boshlang‘ich qiymat
  final RxnString employmentType = RxnString(); // null boshlang‘ich qiymat
  final RxnString sortPrice = RxnString(); // null boshlang‘ich qiymat
  final RxBool isGridView = true.obs;
  final RxBool isLoadingDistricts = false.obs;

  final RxnString minPrice = RxnString(); // Yangi: Narxdan
  final RxnString maxPrice = RxnString(); // Yangi: Narxgacha


  //save language
  void saveLanguage(String language) {
    storage.write('language', language);
    Get.updateLocale(Locale(language));
  }

  void getLanguage() {
    final language = storage.read('language') ?? 'uz';
    Get.updateLocale(Locale(language));
  }

  void setBarIndex(int index) {
    if (index >= 0 && index < 5) { // 5 ta sahifa bor
      barIndex.value = index;
    } else {
      print('Noto‘g‘ri index: $index');
      ShowToast.show('Xatolik', 'Noto‘g‘ri sahifa indeksi', 3, 1);
    }
  }

  Future<void> fetchDeviceInfo() async {
    try {
      if (GetPlatform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceName.value = androidInfo.model ?? 'Noma’lum';
        deviceModel.value = androidInfo.model ?? 'Noma’lum';
        deviceId.value = androidInfo.id ?? 'Noma’lum';
        platform.value = 'Android';
      } else if (GetPlatform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceName.value = iosInfo.name ?? 'Noma’lum';
        deviceModel.value = iosInfo.model ?? 'Noma’lum';
        deviceId.value = iosInfo.identifierForVendor ?? 'Noma’lum';
        platform.value = 'iOS';
      }
      print('Qurilma ma’lumotlari: deviceName=${deviceName.value}, deviceModel=${deviceModel.value}, deviceId=${deviceId.value}, platform=${platform.value}');
    } catch (e) {
      print('Qurilma ma’lumotlarini olishda xato: $e');
    }
  }

  Future<void> checkAndHandleDevice() async {
    try {
      await fetchDeviceInfo();
      if (deviceId.value.isEmpty) {
        print('Qurilma ID topilmadi');
        ShowToast.show('Xatolik', 'Qurilma ID sini olishda xato yuz berdi', 3, 1);
        return;
      }
      // 2. Serverdagi qurilmalarni olish
      final apiController = Get.find<ApiController>();
      await apiController.fetchDevices();

      // 3. Qurilma deviceId sini tekshirish
      final devices = devicesModel.value.data ?? [];
      final matchingDevice = devices.firstWhereOrNull((device) => device.deviceId == deviceId.value);

      if (matchingDevice != null && matchingDevice.id != null) {
        print('Qurilma topildi: deviceId=${matchingDevice.deviceId}, id=${matchingDevice.id}, login amali bajarilmoqda');
        await apiController.loginDevice(matchingDevice.id!);
      } else {
        print('Qurilma topilmadi, yangi qurilma yaratilmoqda');
        await apiController.createDevice();
      }
    } catch (e) {
      print('Qurilma tekshirishda xato: $e');
      ShowToast.show('Xatolik', 'Qurilma tekshirishda xato: $e', 3, 1);
    }
  }

  String getProfileUrl(String? url) {
    const base = 'https://ishtopchi.uz';
    if (url == null || url.trim().isEmpty) {
      return 'https://help.tithe.ly/hc/article_attachments/18804144460951';
    }
    url = url.trim();
    return url.startsWith('http') ? url : '$base/${url.replaceAll(RegExp(r'^(file://)?/+'), '')}';
  }

  void clearWishList() => wishList.clear();

  void setUserMe(UserMe userModel) => userMe.value = userModel;

  void setOtpToken(String token, String phone) {
    otpToken.value = token;
    otpPhone.value = phone;
  }

  void setOtpPhone(String phone) => otpPhone.value = phone;

  void setOtpTokenOnly(String token) => otpToken.value = token;

  void clearOtp() {
    otpToken.value = '';
    otpPhone.value = '';
  }

  String getOtpToken() => otpToken.value;

  String getOtpPhone() => '+998${otpPhone.value}';

  Future<void> saveToken(String token) async {
    await storage.write('token', token);
    globalToken.value = token;
    hasToken.value = token.isNotEmpty;
  }

  String? getToken() {
    final token = storage.read('token') ?? '';
    globalToken.value = token; // Har doim globalToken ni yangilash
    return token;
  }

  Future<void> deleteToken() async {
    await storage.remove('token');
    globalToken.value = '';
    hasToken.value = false;
  }

  String get tokenBearer => storage.read('token') ?? '';

  void clearFilters() {
    selectedRegion.value = null;
    selectedDistrict.value = null;
    selectedCategory.value = null;
    employmentType.value = null;
    sortPrice.value = null;
    minPrice.value = null;
    maxPrice.value = null;
    jobType.value = null;
    districts.clear();
  }

}