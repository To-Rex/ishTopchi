import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = Responsive.screenWidth(context);
    final isSmallScreen = screenWidth < 400;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(16, context)),
      ),
      color: AppColors.darkBlue,
      elevation: 4,
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
              baseColor: AppColors.darkBlue.withOpacity(0.3),
              highlightColor: AppColors.lightGray.withOpacity(0.2),
              child: Container(
                height: Responsive.scaleHeight(isSmallScreen ? 110 : 160, context),
                width: double.infinity,
                color: AppColors.darkBlue,
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
                  baseColor: AppColors.darkBlue.withOpacity(0.3),
                  highlightColor: AppColors.lightGray.withOpacity(0.2),
                  child: Container(
                    height: Responsive.scaleFont(isSmallScreen ? 14 : 16, context),
                    width: screenWidth * 0.6,
                    color: AppColors.darkBlue,
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Kategoriya uchun skeleton
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColors.darkBlue.withOpacity(0.3),
                      highlightColor: AppColors.lightGray.withOpacity(0.2),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.scaleWidth(12, context),
                          vertical: Responsive.scaleHeight(2, context),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkBlue,
                          borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
                          border: Border.all(color: AppColors.lightBlue),
                        ),
                        width: Responsive.scaleWidth(80, context),
                        height: Responsive.scaleHeight(20, context),
                      ),
                    ),
                    const Spacer(),
                    Shimmer.fromColors(
                      baseColor: AppColors.darkBlue.withOpacity(0.3),
                      highlightColor: AppColors.lightGray.withOpacity(0.2),
                      child: Container(
                        height: Responsive.scaleFont(isSmallScreen ? 10 : 11, context),
                        width: Responsive.scaleWidth(60, context),
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Tavsif uchun skeleton
                Shimmer.fromColors(
                  baseColor: AppColors.darkBlue.withOpacity(0.3),
                  highlightColor: AppColors.lightGray.withOpacity(0.2),
                  child: Container(
                    height: Responsive.scaleHeight(isSmallScreen ? 40 : 50, context),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(Responsive.scaleWidth(8, context)),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Maosh va tuman uchun skeleton
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColors.darkBlue.withOpacity(0.3),
                      highlightColor: AppColors.lightGray.withOpacity(0.2),
                      child: Container(
                        height: Responsive.scaleFont(isSmallScreen ? 12 : 14, context),
                        width: Responsive.scaleWidth(100, context),
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColors.darkBlue.withOpacity(0.3),
                      highlightColor: AppColors.lightGray.withOpacity(0.2),
                      child: Container(
                        height: Responsive.scaleFont(isSmallScreen ? 12 : 14, context),
                        width: Responsive.scaleWidth(100, context),
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Foydalanuvchi uchun skeleton
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColors.darkBlue.withOpacity(0.3),
                      highlightColor: AppColors.lightGray.withOpacity(0.2),
                      child: CircleAvatar(
                        radius: Responsive.scaleWidth(isSmallScreen ? 10 : 12, context),
                        backgroundColor: AppColors.darkBlue,
                      ),
                    ),
                    SizedBox(width: Responsive.scaleWidth(4, context)),
                    Shimmer.fromColors(
                      baseColor: AppColors.darkBlue.withOpacity(0.3),
                      highlightColor: AppColors.lightGray.withOpacity(0.2),
                      child: Container(
                        height: Responsive.scaleFont(isSmallScreen ? 9 : 10, context),
                        width: Responsive.scaleWidth(80, context),
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Responsive.scaleHeight(6, context)),
                // Sana va ko‘rishlar uchun skeleton
                Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: AppColors.darkBlue.withOpacity(0.3),
                      highlightColor: AppColors.lightGray.withOpacity(0.2),
                      child: Container(
                        height: Responsive.scaleFont(isSmallScreen ? 8 : 10, context),
                        width: Responsive.scaleWidth(100, context),
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const Spacer(),
                    Shimmer.fromColors(
                      baseColor: AppColors.darkBlue.withOpacity(0.3),
                      highlightColor: AppColors.lightGray.withOpacity(0.2),
                      child: Container(
                        height: Responsive.scaleFont(isSmallScreen ? 9 : 10, context),
                        width: Responsive.scaleWidth(60, context),
                        color: AppColors.darkBlue,
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