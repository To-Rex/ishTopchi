import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Responsive {
  static double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  static double scaleWidth(double size, BuildContext context) {
    final width = screenWidth(context);
    return size * (width / 375); // 375px - standart mobil ekran
  }

  static double scaleHeight(double size, BuildContext context) {
    final height = screenHeight(context);
    return size * (height / 812); // 812px - standart mobil ekran
  }

  static double scaleFont(double size, BuildContext context) {
    final width = screenWidth(context);
    return size * (width / 375);
  }
}
