import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/routes/app_routes.dart';

class ApiController extends GetxController {
  static const String _baseUrl = 'https://ishtopchi.uz/api';
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<void> sendGoogleIdToken(String idToken, String platform) async {
    print('ID Token: $idToken');
    print('Platform: $platform');

    try {
      final response = await _dio.post('$_baseUrl/oauth/google', options: Options(headers: {'accept': '*/*', 'Content-Type': 'application/json'}), data: {'idToken': idToken, 'platform': platform},);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('API javobi: ${response.data}');
        Get.offNamed(AppRoutes.main);
        Get.snackbar('Muvaffaqiyat', 'Google bilan kirish muvaffaqiyatli!', backgroundColor: Colors.green);
      } else {
        print('${response.data}');
        throw Exception('API xatosi: ${response.statusCode} - ${response.data}');
      }
    } catch (error) {
      print('API so‘rovi xatosi: $error');
      throw Exception('API so‘rovi xatosi: $error');
    }
  }
}