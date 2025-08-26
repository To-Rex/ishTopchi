import 'package:flutter/material.dart';

class Responsive {
  // Ekran turini aniqlash uchun chegaralar
  static const double _mobileWidthThreshold = 600; // Mobil ekran uchun maksimal kenglik
  static const double _tabletWidthThreshold = 1024; // Planshet ekran uchun maksimal kenglik

  // Standart o‘lchamlar
  static const double _mobileBaseWidth = 375; // iPhone X kengligi
  static const double _mobileBaseHeight = 812; // iPhone X balandligi
  static const double _tabletBaseWidth = 768; // iPad kengligi
  static const double _tabletBaseHeight = 1024; // iPad balandligi

  // Ekran kengligini olish
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

  // Ekran balandligini olish
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // Qurilma turini aniqlash
  static bool isMobile(BuildContext context) => screenWidth(context) < _mobileWidthThreshold;
  static bool isTablet(BuildContext context) =>
      screenWidth(context) >= _mobileWidthThreshold && screenWidth(context) < _tabletWidthThreshold;
  static bool isDesktop(BuildContext context) => screenWidth(context) >= _tabletWidthThreshold;

  // Kenglikni masshtablash
  static double scaleWidth(double size, BuildContext context) {
    final width = screenWidth(context);
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double baseWidth = isTablet(context) || isDesktop(context) ? _tabletBaseWidth : _mobileBaseWidth;

    // Masshtablash koeffitsientini hisoblash
    double scale = (width / baseWidth) / pixelRatio;
    double scaledSize = size * scale;

    // Minimal va maksimal chegaralar
    final minSize = size * 0.8; // Minimal o‘lcham (80% original o‘lchamdan)
    final maxSize = size * 1.5; // Maksimal o‘lcham (150% original o‘lchamdan)

    return scaledSize.clamp(minSize, maxSize);
  }

  // Balandlikni masshtablash
  static double scaleHeight(double size, BuildContext context) {
    final height = screenHeight(context);
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double baseHeight = isTablet(context) || isDesktop(context) ? _tabletBaseHeight : _mobileBaseHeight;

    // Masshtablash koeffitsientini hisoblash
    double scale = (height / baseHeight) / pixelRatio;
    double scaledSize = size * scale;

    // Minimal va maksimal chegaralar
    final minSize = size * 0.8;
    final maxSize = size * 1.5;

    return scaledSize.clamp(minSize, maxSize);
  }

  // Shrift o‘lchamini masshtablash
  static double scaleFont(double size, BuildContext context) {
    final width = screenWidth(context);
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double baseWidth = isTablet(context) || isDesktop(context) ? _tabletBaseWidth : _mobileBaseWidth;

    // Shriftni kenglik va balandlikka nisbatan masshtablash
    double scale = (width / baseWidth) / pixelRatio;
    double scaledSize = size * scale;

    // Shrift uchun qo‘shimcha chegaralar
    final minFontSize = size * 0.85; // Minimal shrift o‘lchami
    final maxFontSize = size * 1.3;  // Maksimal shrift o‘lchami

    return scaledSize.clamp(minFontSize, maxFontSize);
  }

  // Padding yoki margin uchun masshtablash
  static double scalePadding(double size, BuildContext context) {
    return scaleWidth(size, context); // Padding kenglikka asoslanadi
  }

  // iPad uchun maxsus masshtablash koeffitsienti
  static double tabletScaleFactor(BuildContext context) {
    return isTablet(context) || isDesktop(context) ? 0.9 : 1.0;
  }

  // Konsl loglarini qo‘shish uchun debug funksiyasi
  static void debugScreenInfo(BuildContext context) {
    final width = screenWidth(context);
    final height = screenHeight(context);
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    print('Responsive: Screen width: $width, height: $height, pixelRatio: $pixelRatio');
    print('Responsive: Device type: ${isMobile(context) ? "Mobile" : isTablet(context) ? "Tablet" : "Desktop"}');
  }

  int getCrossAxisCount(BuildContext context) {
    double screenWidth = Responsive.screenWidth(context);
    if (screenWidth >= 1024) {
      // iPad 13-inch yoki undan katta ekranlar uchun
      return 4;
    } else if (screenWidth >= 800) {
      return 3;
    } else if (screenWidth >= 600) {
      return 2;
    } else {
      return 2;
    }
  }
}