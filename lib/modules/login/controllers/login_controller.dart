import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_telegram_login/flutter_telegram_login.dart';
import 'package:ishtopchi/modules/login/views/register_screen.dart';
import '../../../config/routes/app_routes.dart';
import '../../../controllers/api_controller.dart';
import '../views/phone_screen.dart';

class LoginController extends GetxController {
  final isLoading = false.obs;

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
      await _apiController.sendGoogleIdToken(googleAuth.idToken!, 'WEB');
    } catch (e) {
      print('Google Sign-In error: $e');
    }
  }

  Future<UserCredential?> signInWithGoogle2() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        Get.snackbar('Xato', 'Foydalanuvchi kirishni bekor qildi'.tr);
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      print('ID: ${googleUser.id}');
      print('Email: ${googleUser.email}');
      print('Display Name: ${googleUser.displayName}');
      print('Photo URL: ${googleUser.photoUrl}');
      await _apiController.sendGoogleIdToken(googleAuth.idToken!, 'MOBILE');
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      if (e.toString().contains('com.google.android.gms.common.api')) {
        Get.snackbar('Xato', 'Google Play Services o‘rnatilmagan yoki yangilanmagan. Iltimos, yangilang.'.tr);
      } else {
        Get.snackbar('Xato', 'Google Sign-In xatosi: $e'.tr);
      }
      return null;
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
    Get.to(PhoneScreen());
    //Get.to(RegisterScreen());
  }
}