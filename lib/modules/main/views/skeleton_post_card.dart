import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../config/theme/app_colors.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/utils/responsive.dart';

class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.screenWidth(context);
    final isSmallScreen = screenWidth < 400;
    final themeController = Get.find<ThemeController>();
    final isDarkMode = themeController.isDarkMode.value;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context)),
      ),
      color: AppColors.cardColor,
      elevation: isDarkMode ? 0 : 4,
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.scaleWidth(8, context),
        vertical: Responsive.scaleHeight(8, context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rasm uchun skeleton
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Responsive.scaleWidth(16, context)),
            ),
            child: Shimmer.fromColors(
              baseColor:
                  isDarkMode
                      ? AppColors.midBlue.withOpacity(0.3)
                      : AppColors.lightDivider.withOpacity(0.5),
              highlightColor:
                  isDarkMode
                      ? AppColors.lightBlue.withOpacity(0.1)
                      : AppColors.white.withOpacity(0.8),
              child: Container(
                height: Responsive.scaleHeight(
                  isSmallScreen ? 110 : 160,
                  context,
                ),
                width: double.infinity,
                color: isDarkMode ? AppColors.midBlue : AppColors.lightDivider,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(Responsive.scaleWidth(8, context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sarlavha uchun skeleton
                Shimmer.fromColors(
                  baseColor:
                      isDarkMode
                          ? AppColors.midBlue.withOpacity(0.3)
                          : AppColors.lightDivider.withOpacity(0.5),
                  highlightColor:
                      isDarkMode
                          ? AppColors.lightBlue.withOpacity(0.1)
                          : AppColors.white.withOpacity(0.8),
                  child: Container(
                    height: Responsive.scaleFont(
                      isSmallScreen ? 14 : 16,
                      context,
                    ),
                    width: screenWidth * 0.6,
                    color:
                        isDarkMode ? AppColors.midBlue : AppColors.lightDivider,
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Kategoriya uchun skeleton
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor:
                          isDarkMode
                              ? AppColors.midBlue.withOpacity(0.3)
                              : AppColors.lightDivider.withOpacity(0.5),
                      highlightColor:
                          isDarkMode
                              ? AppColors.lightBlue.withOpacity(0.1)
                              : AppColors.white.withOpacity(0.8),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.scaleWidth(12, context),
                          vertical: Responsive.scaleHeight(2, context),
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? AppColors.midBlue
                                  : AppColors.lightDivider,
                          borderRadius: BorderRadius.circular(
                            Responsive.scaleWidth(8, context),
                          ),
                          border: Border.all(
                            color:
                                isDarkMode
                                    ? AppColors.lightBlue
                                    : AppColors.lightPrimary,
                          ),
                        ),
                        width: Responsive.scaleWidth(80, context),
                        height: Responsive.scaleHeight(20, context),
                      ),
                    ),
                    const Spacer(),
                    Shimmer.fromColors(
                      baseColor:
                          isDarkMode
                              ? AppColors.midBlue.withOpacity(0.3)
                              : AppColors.lightDivider.withOpacity(0.5),
                      highlightColor:
                          isDarkMode
                              ? AppColors.lightBlue.withOpacity(0.1)
                              : AppColors.white.withOpacity(0.8),
                      child: Container(
                        height: Responsive.scaleFont(
                          isSmallScreen ? 10 : 11,
                          context,
                        ),
                        width: Responsive.scaleWidth(60, context),
                        color:
                            isDarkMode
                                ? AppColors.midBlue
                                : AppColors.lightDivider,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Tavsif uchun skeleton
                Shimmer.fromColors(
                  baseColor:
                      isDarkMode
                          ? AppColors.midBlue.withOpacity(0.3)
                          : AppColors.lightDivider.withOpacity(0.5),
                  highlightColor:
                      isDarkMode
                          ? AppColors.lightBlue.withOpacity(0.1)
                          : AppColors.white.withOpacity(0.8),
                  child: Container(
                    height: Responsive.scaleHeight(
                      isSmallScreen ? 40 : 50,
                      context,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? AppColors.midBlue
                              : AppColors.lightDivider,
                      borderRadius: BorderRadius.circular(
                        Responsive.scaleWidth(8, context),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Maosh va tuman uchun skeleton
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor:
                          isDarkMode
                              ? AppColors.midBlue.withOpacity(0.3)
                              : AppColors.lightDivider.withOpacity(0.5),
                      highlightColor:
                          isDarkMode
                              ? AppColors.lightBlue.withOpacity(0.1)
                              : AppColors.white.withOpacity(0.8),
                      child: Container(
                        height: Responsive.scaleFont(
                          isSmallScreen ? 12 : 14,
                          context,
                        ),
                        width: Responsive.scaleWidth(100, context),
                        color:
                            isDarkMode
                                ? AppColors.midBlue
                                : AppColors.lightDivider,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor:
                          isDarkMode
                              ? AppColors.midBlue.withOpacity(0.3)
                              : AppColors.lightDivider.withOpacity(0.5),
                      highlightColor:
                          isDarkMode
                              ? AppColors.lightBlue.withOpacity(0.1)
                              : AppColors.white.withOpacity(0.8),
                      child: Container(
                        height: Responsive.scaleFont(
                          isSmallScreen ? 12 : 14,
                          context,
                        ),
                        width: Responsive.scaleWidth(100, context),
                        color:
                            isDarkMode
                                ? AppColors.midBlue
                                : AppColors.lightDivider,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Foydalanuvchi uchun skeleton
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor:
                          isDarkMode
                              ? AppColors.midBlue.withOpacity(0.3)
                              : AppColors.lightDivider.withOpacity(0.5),
                      highlightColor:
                          isDarkMode
                              ? AppColors.lightBlue.withOpacity(0.1)
                              : AppColors.white.withOpacity(0.8),
                      child: CircleAvatar(
                        radius: Responsive.scaleWidth(
                          isSmallScreen ? 10 : 12,
                          context,
                        ),
                        backgroundColor:
                            isDarkMode
                                ? AppColors.midBlue
                                : AppColors.lightDivider,
                      ),
                    ),
                    SizedBox(width: Responsive.scaleWidth(4, context)),
                    Shimmer.fromColors(
                      baseColor:
                          isDarkMode
                              ? AppColors.midBlue.withOpacity(0.3)
                              : AppColors.lightDivider.withOpacity(0.5),
                      highlightColor:
                          isDarkMode
                              ? AppColors.lightBlue.withOpacity(0.1)
                              : AppColors.white.withOpacity(0.8),
                      child: Container(
                        height: Responsive.scaleFont(
                          isSmallScreen ? 9 : 10,
                          context,
                        ),
                        width: Responsive.scaleWidth(80, context),
                        color:
                            isDarkMode
                                ? AppColors.midBlue
                                : AppColors.lightDivider,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Sana va ko'rishlar uchun skeleton
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor:
                          isDarkMode
                              ? AppColors.midBlue.withOpacity(0.3)
                              : AppColors.lightDivider.withOpacity(0.5),
                      highlightColor:
                          isDarkMode
                              ? AppColors.lightBlue.withOpacity(0.1)
                              : AppColors.white.withOpacity(0.8),
                      child: Container(
                        height: Responsive.scaleFont(
                          isSmallScreen ? 8 : 10,
                          context,
                        ),
                        width: Responsive.scaleWidth(100, context),
                        color:
                            isDarkMode
                                ? AppColors.midBlue
                                : AppColors.lightDivider,
                      ),
                    ),
                    const Spacer(),
                    Shimmer.fromColors(
                      baseColor:
                          isDarkMode
                              ? AppColors.midBlue.withOpacity(0.3)
                              : AppColors.lightDivider.withOpacity(0.5),
                      highlightColor:
                          isDarkMode
                              ? AppColors.lightBlue.withOpacity(0.1)
                              : AppColors.white.withOpacity(0.8),
                      child: Container(
                        height: Responsive.scaleFont(
                          isSmallScreen ? 9 : 10,
                          context,
                        ),
                        width: Responsive.scaleWidth(60, context),
                        color:
                            isDarkMode
                                ? AppColors.midBlue
                                : AppColors.lightDivider,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
