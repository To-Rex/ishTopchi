import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import 'package:http/http.dart' as http;

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) {
    final url = options.urlTemplate!
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString())
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{s}', options.subdomains!.first);
    return NetworkImage(url); // NetworkImage orqali plitka yuklanadi
  }
}


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
  final categories = <Map<String, dynamic>>[].obs;
  final selectedRegionId = ''.obs;
  final selectedDistrictId = '0'.obs;
  final isLoadingDistricts = false.obs;
  final selectedLocation = LatLng(41.3111, 69.2401).obs; // Default joylashuv (Toshkent)
  final currentLocation = Rx<LatLng?>(null); // Joriy joylashuv uchun
  final mapController = MapController();
  final isMapReady = false.obs; // Xarita tayyorligini kuzatish
  final currentZoom = 13.0.obs; // Joriy zoom darajasini kuzatish
  final isLocationInitialized = false.obs; // Joylashuv initsializatsiyasi

  final ImagePicker _picker = ImagePicker();
  final ApiController apiController = Get.find<ApiController>();
  final Location _location = Location();

  @override
  void onInit() {
    super.onInit();
    _location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);
    loadRegions();
    loadCategories();
  }

  void startLocationUpdates() {
    if (isLocationInitialized.value) return; // Bir marta initsializatsiya qilingan bo'lsa, qayta ishlamaydi
    _location.onLocationChanged.listen((LocationData locationData) {
      if (locationData.latitude != null && locationData.longitude != null && isMapReady.value) {
        currentLocation.value = LatLng(locationData.latitude!, locationData.longitude!);
        selectedLocation.value = LatLng(locationData.latitude!, locationData.longitude!);
        latitudeController.text = locationData.latitude!.toString();
        longitudeController.text = locationData.longitude!.toString();
        mapController.move(selectedLocation.value, currentZoom.value);
        print('Xarita yangilandi (fon rejimi): ${selectedLocation.value}');
        isLocationInitialized.value = true; // Joylashuv bir marta aniqlandi
      }
    });
  }

  Future<void> loadRegions() async {
    try {
      final fetchedRegions = await apiController.fetchRegions();
      if (fetchedRegions.isNotEmpty) {
        regions.value = fetchedRegions;
        selectedRegionId.value = fetchedRegions.first['id'].toString();
        await loadDistricts(int.parse(selectedRegionId.value));
      }
    } catch (e) {
      print('Viloyatlarni yuklashda xato: $e');
      Get.snackbar('Xato', 'Viloyatlarni yuklashda xato yuz berdi', backgroundColor: AppColors.red, colorText: AppColors.white);
    }
  }

  Future<void> loadCategories() async {
    try {
      final fetchedCategories = await apiController.fetchCategories();
      if (fetchedCategories.isNotEmpty) {
        categories.value = fetchedCategories;
        selectedCategory.value = fetchedCategories.first['id'] as int;
      }
    } catch (e) {
      print('Kategoriyalarni yuklashda xato: $e');
      Get.snackbar('Xato', 'Kategoriyalarni yuklashda xato yuz berdi', backgroundColor: AppColors.red, colorText: AppColors.white);
    }
  }

  Future<void> loadDistricts(int regionId) async {
    try {
      isLoadingDistricts.value = true;
      final fetchedDistricts = await apiController.fetchDistricts(regionId);
      districts.value = fetchedDistricts;
      if (fetchedDistricts.isNotEmpty) {
        selectedDistrictId.value = fetchedDistricts.first['id'].toString();
      } else {
        selectedDistrictId.value = '0';
      }
    } catch (e) {
      print('Tumanlarni yuklashda xato: $e');
      Get.snackbar('Xato', 'Tumanlarni yuklashda xato yuz berdi', backgroundColor: AppColors.red, colorText: AppColors.white);
    } finally {
      isLoadingDistricts.value = false;
    }
  }

  void pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        selectedImage.value = File(pickedFile.path);
      }
    } catch (e) {
      print('Rasm tanlashda xato: $e');
      Get.snackbar('Xato', 'Rasm tanlashda xato yuz berdi', backgroundColor: AppColors.red, colorText: AppColors.white);
    }
  }

  Future<void> getCurrentLocation() async {
    if (!isMapReady.value) {
      Get.snackbar('Xato', 'Xarita hali tayyor emas, iltimos bir oz kuting',
          backgroundColor: AppColors.red, colorText: AppColors.white);
      return;
    }

    if (isLocationInitialized.value && currentLocation.value != null) {
      // Agar joylashuv allaqachon aniqlangan bo'lsa, faqat xaritani yangilaymiz
      selectedLocation.value = currentLocation.value!;
      latitudeController.text = currentLocation.value!.latitude.toString();
      longitudeController.text = currentLocation.value!.longitude.toString();
      mapController.move(selectedLocation.value, currentZoom.value);
      print('Xarita yangilandi (qayta ishlatildi): ${selectedLocation.value}');
      return;
    }

    Get.dialog(const Center(child: CircularProgressIndicator(color: AppColors.lightBlue)), barrierDismissible: false);
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          Get.back();
          Get.snackbar('Xato', 'Joylashuv xizmati yoqilmagan',
              backgroundColor: AppColors.red, colorText: AppColors.white);
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          Get.back();
          Get.snackbar('Xato', 'Joylashuv ruxsati berilmagan',
              backgroundColor: AppColors.red, colorText: AppColors.white);
          return;
        }
      }

      LocationData locationData = await _location.getLocation();
      Get.back();
      if (locationData.latitude != null && locationData.longitude != null) {
        currentLocation.value = LatLng(locationData.latitude!, locationData.longitude!);
        selectedLocation.value = LatLng(locationData.latitude!, locationData.longitude!);
        latitudeController.text = locationData.latitude!.toString();
        longitudeController.text = locationData.longitude!.toString();
        try {
          mapController.move(selectedLocation.value, currentZoom.value);
          print('Xarita yangilandi: ${selectedLocation.value}');
          isLocationInitialized.value = true; // Initsializatsiya tugallandi
        } catch (e) {
          print('Xarita harakatlantirishda xato: $e');
        }
      } else {
        Get.snackbar('Xato', 'Joylashuv ma\'lumotlari olinmadi',
            backgroundColor: AppColors.red, colorText: AppColors.white);
      }
    } catch (e) {
      Get.back();
      print('Joylashuv aniqlashda xato: $e');
      Get.snackbar('Xato', 'Joylashuv aniqlashda xato yuz berdi: $e',
          backgroundColor: AppColors.red, colorText: AppColors.white);
    }
  }

  void updateLocation(LatLng point) {
    if (!isMapReady.value) {
      print('Xarita hali tayyor emas');
      return;
    }
    selectedLocation.value = point;
    latitudeController.text = point.latitude.toString();
    longitudeController.text = point.longitude.toString();
    try {
      mapController.move(point, currentZoom.value);
      print('Xarita yangilandi: $point');
    } catch (e) {
      print('Xarita harakatlantirishda xato: $e');
    }
  }

  void zoomIn() {
    if (!isMapReady.value) {
      print('Xarita hali tayyor emas');
      return;
    }
    currentZoom.value = (currentZoom.value + 1).clamp(1.0, 18.0);
    try {
      mapController.move(selectedLocation.value, currentZoom.value);
      print('Xarita yaqinlashtirildi: Zoom = ${currentZoom.value}');
    } catch (e) {
      print('Yaqinlashtirishda xato: $e');
    }
  }

  void zoomOut() {
    if (!isMapReady.value) {
      print('Xarita hali tayyor emas');
      return;
    }
    currentZoom.value = (currentZoom.value - 1).clamp(1.0, 18.0);
    try {
      mapController.move(selectedLocation.value, currentZoom.value);
      print('Xarita uzoqlashtirildi: Zoom = ${currentZoom.value}');
    } catch (e) {
      print('Uzoqlashtirishda xato: $e');
    }
  }

  bool validateForm() {
    return titleController.text.isNotEmpty &&
        contentController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        selectedRegionId.value.isNotEmpty &&
        selectedDistrictId.value != '0' &&
        selectedCategory.value != 0 &&
        latitudeController.text.isNotEmpty &&
        longitudeController.text.isNotEmpty;
  }

  Future<void> submitAd() async {
    if (!validateForm()) {
      Get.snackbar(
        'Xato',
        'Iltimos, majburiy maydonlarni to\'ldiring (sarlavha, tavsif, telefon, viloyat, tuman, kategoriya, joylashuv)!',
        backgroundColor: AppColors.red,
        colorText: AppColors.white,
      );
      return;
    }

    try {
      // Tokenni olish
      final token = apiController.funcController.getToken();
      if (token == null) {
        Get.snackbar('Xato', 'Token mavjud emas, iltimos login qiling', backgroundColor: AppColors.red, colorText: AppColors.white);
        Get.offNamed('/login');
        return;
      }

      // Telefon raqami validatsiyasi
      if (!phoneNumberController.text.startsWith('+998')) {
        Get.snackbar('Xato', 'Telefon raqami +998 bilan boshlanishi kerak', backgroundColor: AppColors.red, colorText: AppColors.white);
        return;
      }

      // Agar rasm tanlangan bo‘lsa, uni serverga yuklash
      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await apiController.uploadImage(selectedImage.value!, token);
        if (imageUrl == null) {
          Get.snackbar('Xato', 'Rasm yuklashda xato yuz berdi', backgroundColor: AppColors.red, colorText: AppColors.white);
          return;
        }
      }

      // Post ma'lumotlarini tayyorlash
      final Map<String, dynamic> postData = {
        'title': titleController.text,
        'content': contentController.text,
        'phone_number': phoneNumberController.text,
        'email': emailController.text.isNotEmpty ? emailController.text : null,
        'salary_from': salaryFromController.text.isNotEmpty ? int.parse(salaryFromController.text) : null,
        'salary_to': salaryToController.text.isNotEmpty ? int.parse(salaryToController.text) : null,
        'is_open': isOpen.value,
        'category_id': selectedCategory.value,
        'district_id': int.parse(selectedDistrictId.value),
        'location': {
          'title': locationTitleController.text.isNotEmpty ? locationTitleController.text : 'Default Location',
          'latitude': double.parse(latitudeController.text),
          'longitude': double.parse(longitudeController.text),
        },
      };

      if (imageUrl != null && imageUrl.isNotEmpty) {
        postData['image_url'] = imageUrl;
      }

      print('Yuborilayotgan ma\'lumotlar: ${json.encode(postData)}');
      // Postni serverga yuborish
      await apiController.createPost(postData, token);
    } catch (e) {
      print('submitAd xatolik: $e');
      Get.snackbar('Xato', 'E\'lon yuborishda xato yuz berdi: $e', backgroundColor: AppColors.red, colorText: AppColors.white);
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
    mapController.dispose();
    super.onClose();
  }
}