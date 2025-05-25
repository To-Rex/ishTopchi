

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_telegram_login/flutter_telegram_login.dart';
import '../../../config/routes/app_routes.dart';
import '../../../controllers/api_controller.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;
  /*final GoogleSignIn _googleSignInIos = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: '331143083816-7tus0l0ekvvhjok5omabgmo9uejkb1aa.apps.googleusercontent.com', // iOS Client ID
    serverClientId: '331143083816-hu0k8p4p6mjds4rh0d7r0hb6tm67bloj.apps.googleusercontent.com', // Android Client ID
  );
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final googleUser = GoogleSignIn().signIn();*/

  final TelegramLogin _telegramLogin = TelegramLogin(
    '<your_phone_number>',
    '<your_bot_id>',
    '<your_bot_domain>',
  );
  final ApiController _apiController = ApiController();

  Future<void> signInWithGoogle1() async {
    isLoading.value = true;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    try {
      // Google account tanlash
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google account tanlandi');
        return; // User bekor qildi
      }
      //print cleint id ni konsolda chop etish
      print('Client ID: ${_googleSignIn.clientId}');
      print('Client ID: ${_googleSignIn.currentUser}');
      print('Client ID: ${_googleSignIn.forceAccountName}');
      print('Client ID: ${_googleSignIn.serverClientId}');

      // Google auth ma'lumotlarini olish
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('User email address: ${googleUser.email}');
      print('User name: ${googleUser.displayName}');
      await _apiController.sendGoogleIdToken(googleAuth.idToken!, 'MOBILE');
    } catch (e) {
      print('Google Sign-In error: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    final GoogleSignIn _googleSignInIos = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: '331143083816-7tus0l0ekvvhjok5omabgmo9uejkb1aa.apps.googleusercontent.com', // iOS Client ID
      serverClientId: '331143083816-hu0k8p4p6mjds4rh0d7r0hb6tm67bloj.apps.googleusercontent.com', // Android Client ID
    );
    try {
      // Google Sign-In jarayoni
      await _googleSignInIos.signOut(); // Oldingi sessiyani tozalash
      final GoogleSignInAccount? googleUser = await _googleSignInIos.signIn();
      if (googleUser == null) {
        throw Exception('Foydalanuvchi Google Sign-In ni bekor qildi');
      }

      // Google Authentication ma'lumotlari
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('ID Token topilmadi');
      }
      // ID Token ni konsolda chop etish va API'ga yuborish
      print('ID Token: $idToken');
      await _apiController.sendGoogleIdToken(idToken, 'MOBILE');
      // Navigatsiya
    } catch (error) {
      print('Google Sign-In xatosi: $error');
      Get.snackbar('Xato', 'Google kirish xatosi: $error', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> signInWithTelegram() async {
    isLoading.value = true;
    try {
      await _telegramLogin.loginTelegram();
      Get.offNamed(AppRoutes.main);
      Get.snackbar('Muvaffaqiyat', 'Telegram bilan kirish muvaffaqiyatli!', backgroundColor: Colors.green);
    } catch (error) {
      Get.snackbar('Xato', 'Telegram kirish xatosi: $error', backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
