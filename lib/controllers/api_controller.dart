import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/routes/app_routes.dart';
import '../core/models/user_me.dart';
import 'funcController.dart';

class ApiController extends GetxController {
  static const String _baseUrl = 'https://ishtopchi.uz/api';
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final FuncController funcController = Get.put(FuncController()); // ✅ DI orqali chaqiramiz


  Future<void> sendGoogleIdToken(String idToken, String platform) async {
    print('ID Token: $idToken');
    print('Platform: $platform');

    try {
      final response = await _dio.post('$_baseUrl/oauth/google', options: Options(headers: {'accept': '*/*', 'Content-Type': 'application/json'}), data: {'idToken': idToken, 'platform': platform},);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('API javobi: ${response.data}');
        final accessToken = response.data['data']['token']['access_token'];
        await funcController.saveToken(accessToken);

        print('Access token saqlandi: $accessToken');
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


  Future<UserMe?> getMe() async {
    try {
      final token = funcController.getToken();
      if (token == null) {
        throw Exception('Token mavjud emas');
      }

      final response = await _dio.get('$_baseUrl/user/me', options: Options(headers: {'accept': 'application/json', 'Authorization': 'Bearer $token'}));

      if (response.statusCode == 200) {
        final data = response.data;
        print('User ME: $data');
        return UserMe.fromJson(data);
      } else {
        print('Xatolik: ${response.statusCode} - ${response.data}');
        return null;
      }
    } catch (e) {
      print('getMe xatosi: $e');
      return null;
    }
  }
}