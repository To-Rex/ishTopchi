import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';
import '../../../controllers/theme_controller.dart';

class AboutAppScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();
  final ThemeController themeController = Get.find<ThemeController>();

  AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ilova haqida'.tr,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: Responsive.scaleFont(18, context),
          ),
        ),
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textColor,
            size: Responsive.scaleFont(20, context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.scaleWidth(16, context),
          vertical: Responsive.scaleHeight(20, context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo yoki ilova ikoni
            CircleAvatar(
              radius: Responsive.scaleWidth(60, context),
              backgroundColor: AppColors.surfaceColor.withOpacity(0.3),
              child: Icon(
                Icons.app_registration,
                color: AppColors.iconColor,
                size: Responsive.scaleFont(40, context),
              ),
            ),
            SizedBox(height: Responsive.scaleHeight(20, context)),
            // Ilova nomi va versiya
            Text(
              'Ishtopchi',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: Responsive.scaleFont(24, context),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${'Versiya'.tr} ${profileController.appVersion}',
              style: TextStyle(
                color: AppColors.textSecondaryColor,
                fontSize: Responsive.scaleFont(14, context),
              ),
            ),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Ishlab chiquvchi
            _buildInfoItem(
              context,
              Icons.person_outline,
              'Ishlab chiquvchi'.tr,
              'Torex Dev',
              () => _launchURL('https://torexdev.uz'),
            ),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            // Ruxsatlar
            _buildInfoItem(
              context,
              Icons.lock_outline,
              'Ruxsatlar'.tr,
              'Maxfiylik siyosati va shartlar'.tr,
              () => _launchURL('https://ishtopchi.uz/uz/privacy'),
            ),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            // Havolalar
            _buildLinkItem(
              context,
              Icons.link,
              'Veb-sayt'.tr,
              'https://ishtopchi.uz',
              () => _launchURL('https://ishtopchi.uz'),
            ),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Qo'shimcha ma'lumot
            Text(
              '© 2025 Ishtopchi. Barcha huquqlar himoyalangan.'.tr,
              style: TextStyle(
                color: AppColors.textSecondaryColor,
                fontSize: Responsive.scaleFont(12, context),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String title,
    String detail,
    VoidCallback? onTap,
  ) {
    return Container(
      padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
        boxShadow:
            themeController.isDarkMode.value
                ? null
                : [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.iconColor,
              size: Responsive.scaleFont(20, context),
            ),
            SizedBox(width: Responsive.scaleWidth(16, context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Responsive.scaleFont(14, context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: Responsive.scaleFont(12, context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context,
    IconData icon,
    String title,
    String detail,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
      child: Container(
        padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(
            Responsive.scaleWidth(10, context),
          ),
          boxShadow:
              themeController.isDarkMode.value
                  ? null
                  : [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.iconColor,
              size: Responsive.scaleFont(20, context),
            ),
            SizedBox(width: Responsive.scaleWidth(16, context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: Responsive.scaleFont(14, context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    detail,
                    style: TextStyle(
                      color: AppColors.textSecondaryColor,
                      fontSize: Responsive.scaleFont(12, context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Xatolik'.tr,
        'Havola ochilmadi'.tr,
        colorText: AppColors.textColor,
        backgroundColor: AppColors.red,
      );
    }
  }
}
