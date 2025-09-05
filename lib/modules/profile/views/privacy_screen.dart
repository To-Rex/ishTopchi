import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class PrivacyScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xavfsizlik va Maxfiylik'.tr, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context))),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Maxfiylik siyosati
            _buildSectionTitle(context, 'Maxfiylik Siyosati'.tr),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            _buildInfoText(context, 'Sizning shaxsiy ma’lumotlaringiz xavfsiz saqlanadi. Ma’lumotlaringizni ko‘rish va boshqarish uchun quyidagi havolaga o‘ting.'.tr),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildLinkItem(context, 'Maxfiylik siyosati'.tr, 'ishtopchi.uz', () => _launchURL('https://ishtopchi.uz/uz/privacy')),
            SizedBox(height: Responsive.scaleHeight(20, context)),
            // Ma'lumotlar xavfsizligi
            _buildSectionTitle(context, 'Ma’lumotlar Xavfsizligi'.tr),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            _buildInfoText(context, 'Biz eng zamonaviy shifrlash usullaridan foydalanamiz. Ma’lumotlaringiz faqat ruxsat berilgan holatda ishlatiladi.'.tr),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildLinkItem(context, 'Xavfsizlik qoidalari'.tr, 'ishtopchi.uz', () => _launchURL('https://ishtopchi.uz/uz/data-security')),
            SizedBox(height: Responsive.scaleHeight(20, context)),
            // Sozlamalar
            _buildSectionTitle(context, 'Maxfiylik Sozlamalari'.tr),
            SizedBox(height: Responsive.scaleHeight(8, context)),
            _buildInfoText(context, 'Shaxsiy ma’lumotlaringizni boshqarish uchun sozlamalarni tekshiring.'.tr),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildActionItem(context, 'Maxfiylik sozlamalarini ko‘rish'.tr, () => _openSettings(context)),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Mualliflik
            Center(child: Text('© 2025 Ishtopchi. Barcha huquqlar himoyalangan.'.tr, style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context), fontStyle: FontStyle.italic)))
          ]
        )
      )
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.white,
        fontSize: Responsive.scaleFont(18, context),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoText(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.lightGray,
        fontSize: Responsive.scaleFont(14, context),
        height: 1.5,
      ),
    );
  }

  Widget _buildLinkItem(BuildContext context, String title, String detail, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
      child: Container(
        padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          boxShadow: [BoxShadow(color: AppColors.darkNavy.withAlpha(50), blurRadius: 4, offset: Offset(0, 2))]
        ),
        child: Row(
          children: [
            Icon(Icons.link, color: AppColors.lightBlue, size: Responsive.scaleFont(20, context)),
            SizedBox(width: Responsive.scaleWidth(16, context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500)),
                  Text(
                    detail,
                    style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(12, context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildActionItem(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
      child: Container(
        padding: EdgeInsets.all(Responsive.scaleWidth(12, context)),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(Responsive.scaleWidth(10, context)),
          boxShadow: [BoxShadow(color: AppColors.darkNavy.withAlpha(50), blurRadius: 4, offset: Offset(0, 2))]
        ),
        child: Row(
          children: [
            Icon(Icons.settings, color: AppColors.lightBlue, size: Responsive.scaleFont(20, context)),
            SizedBox(width: Responsive.scaleWidth(16, context)),
            Text(title, style: TextStyle(color: AppColors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w500))
          ]
        )
      )
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Xatolik'.tr, 'Havola ochilmadi'.tr, colorText: AppColors.white, backgroundColor: AppColors.red);
    }
  }

  void _openSettings(BuildContext context) {
    // Bu yerda maxfiylik sozlamalarini ochish uchun maxsus ekran yoki navigatsiya qo'shilishi mumkin
    Get.snackbar('Xabar'.tr, 'Maxfiylik sozlamalari hozircha mavjud emas'.tr, colorText: AppColors.white, backgroundColor: AppColors.lightBlue.withAlpha(100));
  }
}