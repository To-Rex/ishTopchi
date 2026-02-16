import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/common/widgets/text_small.dart';
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
      () => SizedBox.expand(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.scaleWidth(32, context),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: Responsive.scaleWidth(120, context),
                      height: Responsive.scaleWidth(120, context),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor.withOpacity(0.1),
                            AppColors.secondaryColor.withOpacity(0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        LucideIcons.userCheck,
                        size: Responsive.scaleWidth(56, context),
                        color: AppColors.iconColor.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(24, context)),

                TextSmall(
                  text: "Siz ro‘yxatdan o‘tmagansiz".tr,
                  fontSize: Responsive.scaleFont(20, context),
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.scaleHeight(12, context)),

                TextSmall(
                  text:
                      "Iltimos, hisobingizga kiring yoki ro‘yxatdan o‘ting".tr,
                  fontSize: Responsive.scaleFont(14, context),
                  color: AppColors.textSecondaryColor,
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                ),
                SizedBox(height: Responsive.scaleHeight(32, context)),
                GestureDetector(
                  onTap: () => Get.offNamed('/login'),
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) => setState(() => _isPressed = false),
                  child: AnimatedScale(
                    scale: _isPressed ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 100),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scaleWidth(24, context),
                        vertical: Responsive.scaleHeight(14, context),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primaryColor,
                            AppColors.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryColor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.logIn,
                            size: Responsive.scaleWidth(18, context),
                            color: AppColors.white,
                          ),
                          SizedBox(width: Responsive.scaleWidth(8, context)),
                          TextSmall(
                            text: "Ro‘yxatdan o‘ting va boshlang!".tr,
                            fontSize: Responsive.scaleFont(14, context),
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
