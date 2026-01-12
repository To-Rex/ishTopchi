import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_colors.dart';
import '../../controllers/theme_controller.dart';
import '../../core/utils/responsive.dart';

class NotLogged extends StatefulWidget {
  const NotLogged({super.key});

  @override
  State<NotLogged> createState() => _NotLoggedState();
}

class _NotLoggedState extends State<NotLogged>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(
                  LucideIcons.userCheck,
                  size: 80.sp,
                  color: AppColors.textColor,
                ),
              ),
            ),
            SizedBox(height: 20.sp),
            Text(
              "Siz ro'yxatdan o'tmagansiz".tr,
              style: TextStyle(
                fontSize: Responsive.scaleFont(20, context),
                color: AppColors.textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.sp),
            Text(
              "Iltimos, hisobingizga kiring yoki ro'yxatdan o'ting".tr,
              style: TextStyle(
                fontSize: Responsive.scaleFont(16, context),
                color: AppColors.textColor,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.sp),
            GestureDetector(
              onTap: () => Get.offNamed('/login'),
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.midBlue, AppColors.lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.sp,
                    vertical: 12.sp,
                  ),
                  child: Text(
                    "Ro'yxatdan o'ting va boshlang!".tr,
                    style: TextStyle(
                      fontSize: Responsive.scaleFont(16, context),
                      color: AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
