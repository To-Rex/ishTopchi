import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../config/routes/app_routes.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final LoginController controller = LoginController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  themeController.isDarkMode.value
                      ? [AppColors.darkBlue, AppColors.darkNavy]
                      : [AppColors.lightBackground, AppColors.lightSurface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.scaleWidth(
                    AppDimensions.paddingLarge,
                    context,
                  ),
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(), // yuqorisini bo‘sh qoldiramiz
                    // MARKAZDAGI BLOK
                    Expanded(
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 100),
                            Text(
                              'Ishtopchi'.tr,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineLarge?.copyWith(
                                fontSize: Responsive.scaleFont(48, context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ish e’lonlari platformasi'.tr,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondaryColor,
                                fontSize: Responsive.scaleFont(16, context),
                              ),
                            ),
                            const SizedBox(height: 48),

                            //platform is android
                            if (Platform.isAndroid)
                              Obx(
                                () => CustomButton(
                                  text: 'Google bilan kirish'.tr,
                                  onPressed:
                                      controller.isLoading.value
                                          ? null
                                          : Platform.isIOS
                                          ? controller.signInWithGoogle
                                          : controller.signInWithGoogle1,
                                  icon: Bootstrap.google,
                                  isLoading: controller.isLoading.value,
                                  backgroundColor: AppColors.white,
                                  textColor: AppColors.midBlue,
                                ),
                              ),
                            if (Platform.isIOS)
                              Obx(
                                () => CustomButton(
                                  text: 'Apple bilan kirish'.tr,
                                  onPressed:
                                      controller.isLoading.value
                                          ? null
                                          : controller.signInWithApple,
                                  icon: Bootstrap.apple,
                                  isLoading: controller.isLoading.value,
                                  backgroundColor: AppColors.white,
                                  textColor: AppColors.midBlue,
                                ),
                              ),
                            const SizedBox(height: 16),

                            Obx(
                              () => CustomButton(
                                text: 'Telegram bilan kirish'.tr,
                                onPressed:
                                    controller.isLoading.value
                                        ? null
                                        : controller.signInWithTelegram,
                                icon: Icons.telegram,
                                isLoading: controller.isLoading.value,
                                textColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),

                            Text(
                              'Yangi foydalanuvchi? Ro‘yxatdan o‘ting'.tr,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryColor,
                                fontSize: Responsive.scaleFont(14, context),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            Obx(
                              () =>
                                  controller.isLoading.value
                                      ? const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.lightGray,
                                            ),
                                      )
                                      : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // PASTKI "DAVOM ETISH" TUGMASI
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextButton(
                        onPressed: () => Get.offNamed(AppRoutes.main),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: Text('Davom etish'.tr),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
