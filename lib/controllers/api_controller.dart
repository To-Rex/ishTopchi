import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/routes/app_routes.dart';
import '../core/models/user_me.dart';
import '../modules/login/views/otp_verification_screen.dart';
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
        getMe();
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

  Future generateOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/otp-based-auth/generate-otp',
        data: {'phoneNumber': phoneNumber},
        options: Options(headers: {'accept': '*/*', 'Content-Type': 'application/json'})
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final encryptedOtp = response.data;
        print('OTP yuborildi. Encrypted OTP: $encryptedOtp');
        //funcController.setOtpToken(encryptedOtp, phoneNumber);
        funcController.setOtpTokenOnly(encryptedOtp);
        funcController.setOtpPhone(phoneNumber);
        Get.to(() => OtpVerificationScreen(phone: phoneNumber.trim()), transition: Transition.fadeIn);
      } else {
        print('OTP yuborishda xatolik: ${response.statusCode}');
      }
    } catch (e) {
      print('generateOtp xatolik: $e');
    }
  }

  Future<void> loginWithOtp({required String otp}) async {
    final fingerprint = await funcController.getOtpToken(); // JWT fingerprint
    final phone = await funcController.getOtpPhone();

    print('Fingerprint: $fingerprint');
    print('Phone: $phone');
    print('OTP: $otp');

    try {
      final response = await _dio.post(
        '$_baseUrl/otp-based-auth/login',
        data: {
          'phone_number': '+998995340313',
          'otp': '851909',
          'fingerprint': 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbmNyeXB0ZWRPdHAiOiIxODBiNGQ3YThiYjM5NjQ2ZjJlZGQyMzU5ZTA1OWVkNWNlODQ0ZDBlM2Y5ZTQxOGVjYjk2ODQ5MzgyODc0OWMxNGU0NjNlNzQxZmJiIiwicGhvbmVOdW1iZXIiOiI5OTUzNDAzMTMiLCJ1c2VyQWdlbnQiOiJEYXJ0LzMuOCAoZGFydDppbykiLCJpcEFkZHJlc3MiOiI6OmZmZmY6MTI3LjAuMC4xIiwiZXhwIjoxNzUwNzM5MTUxLCJpYXQiOjE3NTA3Mzg4NTF9.lXEn-uy4e_gYiQjfQYdffj5NNKdbbZ2SRsUpLpplRFEuxleescngmIZbwH-eJqBCf_zT8wOtXkRlddcOcmmS7GdHbaA2h2lb4IxQwGS2keIlBfDjf_lOuWvqR1mvSxS_q9HZbia-2NONGic87FZPSDDqTw6jYyB6Zv9YZQtY73gjiCWbGmcYVKOAYHgRRrS9WaAXNWNmeg-4kvuAbZ5ev1Oy-d0YtEDe8-YbJRwjeIgd0pclCb08VCrls_L3zt5Kz0_sIJdr74mOfYhD-YtWPlcPRFvFX2NoBPMGrsXysBMm8BgmRcZ0ta6sQUtXINMD24iNYcOP3c90RU6QJh7plQ'
        },
        options: Options(
          headers: {
            'accept': '*/*',
            'Content-Type': 'application/json',
            // ❌ 'Authorization' kerak emas bu yerda!
          },
        ),
      );

      print('✅ Javob: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final accessToken = response.data['data']['token']['access_token'];
        await funcController.saveToken(accessToken);
        print('✅ Login muvaffaqiyatli. Access Token: $accessToken');
      } else {
        print('❌ Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ loginWithOtp xatolik: $e');
    }
  }

  Future<bool> completeRegistration({required String firstName, required String lastName, required int districtId, required String birthDate, required String token}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/otp-based-auth/complete-registration',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'district_id': districtId,
          'birth_date': birthDate,
        },
        options: Options(headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Ro‘yxatdan o‘tish yakunlandi.');
        return true;
      } else {
        print('completeRegistration xatolik: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('completeRegistration xatolik: $e');
      return false;
    }
  }
}