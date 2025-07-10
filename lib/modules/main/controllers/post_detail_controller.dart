import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/show_toast.dart';

class PostDetailController extends GetxController {
  final mapController = MapController();
  final isMapReady = false.obs;
  final currentZoom = 13.0.obs;
  final currentLocation = Rx<LatLng?>(null);
  final selectedLocation = Rx<LatLng?>(null);
  static const double _optimalZoom = 13.0;

  @override
  void onInit() {
    super.onInit();
  }

  void setInitialLocation(LatLng location) {
    selectedLocation.value = location;
    currentZoom.value = _optimalZoom;
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

  Future<void> getCurrentLocation(void Function(LatLng, double) onMove) async {
    if (!isMapReady.value) {
      ShowToast.show('Xato', 'Xarita hali tayyor emas, iltimos bir oz kuting', 3, 1);
      return;
    }

    bool hasPermission = await checkLocationPermission();
    print('Has permission: $hasPermission');
    if (!hasPermission) {
      return;
    }

    try {
      print('Getting current location...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      print('Current location obtained: ${position.latitude}, ${position.longitude}');
      final newLocation = LatLng(position.latitude, position.longitude);
      currentLocation.value = newLocation;
      try {
        double targetZoom = _optimalZoom;
        if (currentZoom.value > 15.0 || currentZoom.value < 10.0) {
          targetZoom = _optimalZoom;
        } else {
          targetZoom = currentZoom.value;
        }

        onMove(newLocation, targetZoom);
        print('Xarita yangilandi (joriy joylashuv): $newLocation, Zoom: $targetZoom');
      } catch (e) {
        print('Xarita harakatlantirishda xato: $e');
        ShowToast.show('Xato', 'Xarita yangilashda xato: $e', 3, 1);
      }
    } catch (e) {
      print('Joylashuv aniqlashda xato: $e');
      ShowToast.show('Xato', 'Joylashuv aniqlashda xato yuz berdi: $e', 3, 1);
    }
  }

  void zoomIn(void Function(LatLng, double) onMove) {
    if (!isMapReady.value) {
      print('Xarita hali tayyor emas');
      return;
    }
    currentZoom.value = (currentZoom.value + 1).clamp(1.0, 18.0);
    try {
      onMove(selectedLocation.value!, currentZoom.value);
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
      onMove(selectedLocation.value!, currentZoom.value);
      print('Xarita uzoqlashtirildi: Zoom = ${currentZoom.value}');
    } catch (e) {
      print('Uzoqlashtirishda xato: $e');
      ShowToast.show('Xato', 'Uzoqlashtirishda xato: $e', 3, 1);
    }
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }
}