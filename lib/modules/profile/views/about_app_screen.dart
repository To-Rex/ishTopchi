import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class AboutAppScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ilova haqida', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context))),
        backgroundColor: AppColors.darkNavy,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightGray, size: Responsive.scaleFont(20, context)),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
      ),
      backgroundColor: AppColors.darkNavy,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.scaleWidth(16, context), vertical: Responsive.scaleHeight(20, context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo yoki ilova ikoni
            CircleAvatar(
              radius: Responsive.scaleWidth(60, context),
              backgroundColor: AppColors.darkBlue.withOpacity(0.3),
              child: Icon(Icons.app_registration, color: AppColors.lightBlue, size: Responsive.scaleFont(40, context)),
            ),
            SizedBox(height: Responsive.scaleHeight(20, context)),
            // Ilova nomi va versiya
            Text(
              'Ishtopchi',
              style: TextStyle(
                color: AppColors.white,
                fontSize: Responsive.scaleFont(24, context),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Versiya 1.0.0',
              style: TextStyle(
                color: AppColors.lightGray,
                fontSize: Responsive.scaleFont(14, context),
              ),
            ),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Ishlab chiquvchi
            _buildInfoItem(context, Icons.person_outline, 'Ishlab chiquvchi', 'xAI Team'),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            // Ruxsatlar
            _buildInfoItem(context, Icons.lock_outline, 'Ruxsatlar', 'Maxfiylik siyosati va shartlar'),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            // Havolalar
            _buildLinkItem(context, Icons.link, 'Veb-sayt', 'https://x.ai', () => _launchURL('https://x.ai')),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Qo‘shimcha ma’lumot
            Text(
              '© 2025 Ishtopchi. Barcha huquqlar himoyalangan.',
              style: TextStyle(
                color: AppColors.lightGray,
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

  Widget _buildInfoItem(BuildContext context, IconData icon, String title, String detail) {
    return Container(
      padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withAlpha(50),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.lightBlue, size: Responsive.scaleFont(20, context)),
          SizedBox(width: Responsive.scaleWidth(16, context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500),
                ),
                Text(
                  detail,
                  style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, IconData icon, String title, String detail, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
      child: Container(
        padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkNavy.withAlpha(50),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.lightBlue, size: Responsive.scaleFont(20, context)),
            SizedBox(width: Responsive.scaleWidth(16, context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500),
                  ),
                  Text(
                    detail,
                    style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context)),
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
      Get.snackbar('Xatolik', 'Havola ochilmadi', colorText: AppColors.white, backgroundColor: AppColors.red);
    }
  }
}