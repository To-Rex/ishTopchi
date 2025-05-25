import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:sign_in_button/sign_in_button.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final LoginController controller = LoginController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkBlue, AppColors.darkNavy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(AppDimensions.paddingLarge, context)),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ishtopchi',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: Responsive.scaleFont(56, context),
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: Responsive.scaleHeight(AppDimensions.paddingMedium, context)),
                  Text(
                    'Ish e’lonlari platformasi',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: Responsive.scaleFont(18, context),
                    ),
                  ),
                  SizedBox(height: Responsive.scaleHeight(60, context)),
                  Obx(() => CustomButton(
                      text: 'Telegram bilan kirish',
                      onPressed: controller.isLoading.value ? null : Platform.isIOS ? controller.signInWithGoogle : controller.signInWithGoogle1,
                      //onPressed: (){},
                      //icon: Icons.telegram,
                      icon: Bootstrap.google,
                      isLoading: controller.isLoading.value,
                      backgroundColor: AppColors.white,
                      textColor: AppColors.midBlue,
                      iconSize: Responsive.scaleWidth(AppDimensions.iconSizeMedium, context), // Ikon o‘lchami
                    ),
                  ),
                  SizedBox(height: Responsive.scaleHeight(AppDimensions.paddingMedium, context)),
                  Obx(() => CustomButton(
                      text: 'Telegram bilan kirish',
                      onPressed: controller.isLoading.value ? null : controller.signInWithTelegram,
                      icon: Icons.telegram,
                      isLoading: controller.isLoading.value,
                      textColor: AppColors.white,
                      iconSize: Responsive.scaleWidth(AppDimensions.iconSizeMedium, context), // Ikon o‘lchami
                    ),
                  ),
                  SizedBox(height: Responsive.scaleHeight(AppDimensions.paddingLarge, context)),
                  Text(
                    'Yangi foydalanuvchi? Google yoki Telegram orqali ro\'yhatdan o\'ting',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: Responsive.scaleFont(14, context),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Responsive.scaleHeight(AppDimensions.paddingMedium, context)),
                  Obx(
                        () => controller.isLoading.value
                        ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightGray),
                    )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}