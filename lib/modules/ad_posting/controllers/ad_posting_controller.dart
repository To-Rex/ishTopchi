import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../controllers/api_controller.dart';
import '../../../core/services/show_toast.dart';
import 'dart:convert';

class CachedTileProvider extends TileProvider {
  @override
  ImageProvider<Object> getImage(TileCoordinates coordinates, TileLayer options) {
    final url = options.urlTemplate!
        .replaceAll('{x}', coordinates.x.toString())
        .replaceAll('{y}', coordinates.y.toString())
        .replaceAll('{z}', coordinates.z.toString())
        .replaceAll('{s}', options.subdomains.first);
    return NetworkImage(url);
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
  final selectedLocation = LatLng(41.3111, 69.2401).obs;
  final currentLocation = Rx<LatLng?>(null);
  final mapController = MapController();
  final isMapReady = false.obs;
  final currentZoom = 13.0.obs;
  final isLocationInitialized = false.obs;
  static const double _optimalZoom = 13.0;

  final ImagePicker _picker = ImagePicker();
  final ApiController apiController = Get.find<ApiController>();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final token = await _waitForToken();
    if (token == null) {
      ShowToast.show('Xato', 'Token mavjud emas, iltimos login qiling', 3, 1);
      Get.offNamed('/login');
      return;
    }
    await Future.wait([
      loadRegions(),
      loadCategories(),
    ]);
  }

  Future<String?> _waitForToken() async {
    int retries = 5;
    while (retries > 0) {
      final token = apiController.funcController.getToken();
      if (token != null && token.isNotEmpty) {
        return token;
      }
      await Future.delayed(const Duration(milliseconds: 500));
      retries--;
    }
    return null;
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
      ShowToast.show('Xato', 'Viloyatlarni yuklashda xato yuz berdi', 3, 1);
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
      ShowToast.show('Xato', 'Kategoriyalarni yuklashda xato yuz berdi', 3, 1);
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
      ShowToast.show('Xato', 'Tumanlarni yuklashda xato yuz berdi', 3, 1);
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
      ShowToast.show('Xato', 'Rasm tanlashda xato yuz berdi', 3, 1);
    }
  }

  Future<bool> checkLocationPermission() async {
    print('Checking location service status...');
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ShowToast.show(
        'Joylashuv o‘chirilgan',
        'Iltimos, iPhone Sozlamalaridan Location Services ni yoqing.',
        4, 1,
      );
      return false;
    }

    var status = await Permission.locationWhenInUse.status;
    print('Current permission status: $status');

    if (status.isGranted) {
      print('✅ Permission GRANTED');
      return true;
    }

    if (status.isDenied || status.isRestricted) {
      print('⚠️ Permission DENIED/RESTRICTED - requesting...');
      final newStatus = await Permission.locationWhenInUse.request();
      print('Requested permission result: $newStatus');

      if (newStatus.isGranted) {
        print('✅ Permission NOW GRANTED');
        return true;
      } else {
        ShowToast.show(
          'Ruxsat berilmadi',
          'Siz ilovada joylashuv ruxsatini bermadingiz. Sozlamalardan yoqing va ilovani qayta ishga tushiring.',
          5, 1,
        );
        await openAppSettings();
        return false;
      }
    }

    if (status.isPermanentlyDenied) {
      print('❌ Permission PERMANENTLY_DENIED');
      ShowToast.show(
        'Ruxsat kerak',
        'Siz joylashuv ruxsatini doimiy rad etgansiz. Iltimos, Sozlamalardan yoqing va ilovani qayta ishga tushiring.',
        5, 1,
      );
      await openAppSettings();
      return false;
    }

    ShowToast.show(
      'Xato',
      'Joylashuv ruxsatini aniqlashda muammo yuz berdi.',
      3, 1,
    );
    return false;
  }

  Future<void> initializeApp() async {
    print('MainController: Initializing app...');
    if (await checkLocationPermission()) {
      try {
        Position position = await Geolocator.getCurrentPosition();
        print('MainController: Initial location: ${position.latitude}, ${position.longitude}');
      } catch (e) {
        print('MainController: Initial location error: $e');
      }
    }
  }

  Future<void> getCurrentLocation(void Function(LatLng, double) onMove) async {
    if (!isMapReady.value) {
      ShowToast.show('Xato', 'Xarita hali tayyor emas, iltimos bir oz kuting', 3, 1);
      return;
    }

    // Ruxsatlarni tekshirish va so‘rash
    bool hasPermission = await checkLocationPermission();
    print('Has permission: $hasPermission');
    if (!hasPermission) {
      return;
    }

    try {
      print('Getting current location...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      print('Current location obtained: ${position.latitude}, ${position.longitude}');
      final newLocation = LatLng(position.latitude, position.longitude);
      currentLocation.value = newLocation;
      selectedLocation.value = newLocation;
      latitudeController.text = position.latitude.toString();
      longitudeController.text = position.longitude.toString();
      try {
        double targetZoom = _optimalZoom;
        if (currentZoom.value > 15.0 || currentZoom.value < 10.0) {
          targetZoom = _optimalZoom;
        } else {
          targetZoom = currentZoom.value;
        }

        onMove(newLocation, targetZoom);
        print('Xarita yangilandi (joriy joylashuv): $newLocation, Zoom: $targetZoom');
        isLocationInitialized.value = true;
      } catch (e) {
        print('Xarita harakatlantirishda xato: $e');
        ShowToast.show('Xato', 'Xarita yangilashda xato: $e', 3, 1);
      }
    } catch (e) {
      print('Joylashuv aniqlashda xato: $e');
      ShowToast.show('Xato', 'Joylashuv aniqlashda xato yuz berdi: $e', 3, 1);
    }
  }

  void updateLocation(LatLng point, void Function(LatLng, double) onMove) {
    if (!isMapReady.value) {
      print('Xarita hali tayyor emas');
      return;
    }
    selectedLocation.value = point;
    latitudeController.text = point.latitude.toString();
    longitudeController.text = point.longitude.toString();
    try {
      onMove(point, currentZoom.value);
      print('Xarita yangilandi (tanlangan joy): $point, Zoom: ${currentZoom.value}');
    } catch (e) {
      print('Xarita harakatlantirishda xato: $e');
      ShowToast.show('Xato', 'Xarita yangilashda xato: $e', 3, 1);
    }
  }

  void zoomIn(void Function(LatLng, double) onMove) {
    if (!isMapReady.value) {
      print('Xarita hali tayyor emas');
      return;
    }
    currentZoom.value = (currentZoom.value + 1).clamp(1.0, 18.0);
    try {
      onMove(selectedLocation.value, currentZoom.value);
      print('Xarita yaqinlashtirildi: Zoom = ${currentZoom.value}');
    } catch (e) {
      print('Yaqinlashtirishda xato: $e');
      ShowToast.show('Xato', 'Yaqinlashtirishda xato: $e', 3, 1);
    }
  }

  void zoomOut(void Function(LatLng, double) onMove) {
    if (!isMapReady.value) {
      print('Xarita hali tayyor emas');
      return;
    }
    currentZoom.value = (currentZoom.value - 1).clamp(1.0, 18.0);
    try {
      onMove(selectedLocation.value, currentZoom.value);
      print('Xarita uzoqlashtirildi: Zoom = ${currentZoom.value}');
    } catch (e) {
      print('Uzoqlashtirishda xato: $e');
      ShowToast.show('Xato', 'Uzoqlashtirishda xato: $e', 3, 1);
    }
  }

  bool validateForm() {
    print('Validating form...');
    print('Title: ${titleController.text}');
    print('Content: ${contentController.text}');
    print('Phone Number: ${phoneNumberController.text}');
    print('Region: ${selectedRegionId.value}');
    print('District: ${selectedDistrictId.value}');
    print('Category: ${selectedCategory.value}');
    print('Latitude: ${latitudeController.text}');
    print('Longitude: ${longitudeController.text}');

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
      ShowToast.show(
          'Xato', 'Iltimos, majburiy maydonlarni to‘ldiring (sarlavha, tavsif, telefon, viloyat, tuman, kategoriya, joylashuv)!', 3, 1);
      return;
    }

    try {
      final token = apiController.funcController.getToken();
      if (token == null) {
        ShowToast.show('Xato', 'Token mavjud emas, iltimos login qiling', 3, 1);
        Get.offNamed('/login');
        return;
      }

      String? imageUrl;
      if (selectedImage.value != null) {
        imageUrl = await apiController.uploadImage(selectedImage.value!, token);
        if (imageUrl == null) {
          ShowToast.show('Xato', 'Rasm yuklashda xato yuz berdi', 3, 1);
          return;
        }
      }

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
        postData['picture_url'] = imageUrl;
      }

      print('Yuborilayotgan ma\'lumotlar: ${jsonEncode(postData)}');
      await apiController.createPost(postData, token);
      ShowToast.show('Muvaffaqiyat', 'E’lon muvaffaqiyatli yuborildi', 1, 1);
      Get.back();
    } catch (e) {
      print('submitAd xatolik: $e');
      ShowToast.show('Xato', 'E\'lon yuborishda xato yuz berdi: $e', 3, 1);
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