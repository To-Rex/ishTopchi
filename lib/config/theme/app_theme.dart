import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.darkNavy,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.lightGray,
            shadows: [
              Shadow(blurRadius: 12, color: Colors.black45, offset: Offset(2, 2)),
            ],
          ),
          headlineMedium: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: AppColors.lightBlue,
            letterSpacing: 0.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: AppColors.lightBlue,
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.lightGray,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.midBlue,
            foregroundColor: AppColors.lightGray,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            elevation: 10,
            shadowColor: Colors.black45,
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      );
}
