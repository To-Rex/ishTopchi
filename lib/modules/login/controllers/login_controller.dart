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

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    final GoogleSignIn _googleSignInIos = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: '331143083816-kir3q80qqfi63k3ons61ak2sat8n8pdj.apps.googleusercontent.com', // iOS Client ID
      serverClientId: '331143083816-kir3q80qqfi63k3ons61ak2sat8n8pdj.apps.googleusercontent.com', // Android Client ID
    );
    //final GoogleSignIn _googleSignInIos = GoogleSignIn();
    try {
      // Google account tanlash
      final GoogleSignInAccount? googleUser = await _googleSignInIos.signIn();
      if (googleUser == null) {
        print('Google account tanlandi');

        return; // User bekor qildi
      }
      //print cleint id ni konsolda chop etish
      print('Client ID: ${_googleSignInIos.clientId}');
      print('Client ID: ${_googleSignInIos.currentUser}');
      print('Client ID: ${_googleSignInIos.forceAccountName}');
      print('Client ID: ${_googleSignInIos.serverClientId}');

      // Google auth ma'lumotlarini olish
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('User email address: ${googleUser.email}');
      print('User name: ${googleUser.displayName}');
      await _apiController.sendGoogleIdToken(googleAuth.idToken!, 'IOS');

    } catch (e) {
      isLoading.value = false;
      print('Google Sign-In error: $e');
    }
  }

  Future<void> signInWithTelegram() async {
    Get.to(PhoneScreen());
    //Get.to(RegisterScreen());
  }
}