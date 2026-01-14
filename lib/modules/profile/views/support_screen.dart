import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';
import '../../../controllers/theme_controller.dart';

class SupportScreen extends StatefulWidget {
  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Qo‘llab-quvvatlash'.tr,
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
          onPressed: () => Get.back(),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kontaktlar ro'yxati
            _buildContactItem(
              context,
              Icons.phone,
              'Telefon'.tr,
              '+998 90 123 45 67',
              () => _launchURL('tel:+998901234567'),
            ),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildContactItem(
              context,
              Icons.email,
              'Email'.tr,
              'support@ishtopchi.uz',
              () => _launchURL('mailto:support@ishtopchi.uz'),
            ),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildContactItem(
              context,
              Icons.telegram,
              'Telegram'.tr,
              '@IshtopchiSupport',
              () => _launchURL('https://t.me/IshtopchiSupport'),
            ),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Qo'shimcha yordam
            Text(
              'Yordam markazi'.tr,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: Responsive.scaleFont(16, context),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildHelpItem(
              context,
              'Ko‘p beriladigan savollar'.tr,
              () => _launchURL('https://ishtopchi.uz/faq'),
            ),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            _buildHelpItem(
              context,
              'Qo‘llanma'.tr,
              () => _launchURL('https://ishtopchi.uz/guide'),
            ),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Yordam so'rash tugmasi
            Center(
              child: ElevatedButton(
                onPressed: () => _showSupportRequestDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.scaleWidth(15, context),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: Responsive.scaleHeight(12, context),
                    horizontal: Responsive.scaleWidth(40, context),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Yordam so\'rash'.tr,
                  style: TextStyle(
                    fontSize: Responsive.scaleFont(16, context),
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(
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
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withAlpha(50),
              blurRadius: 4,
              offset: Offset(0, 2),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String title,
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
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withAlpha(50),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: AppColors.iconColor,
              size: Responsive.scaleFont(20, context),
            ),
            SizedBox(width: Responsive.scaleWidth(16, context)),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: Responsive.scaleFont(14, context),
                fontWeight: FontWeight.w500,
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

  void _showSupportRequestDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Responsive.scaleWidth(12, context),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Yordam so\'rash'.tr,
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: Responsive.scaleFont(16, context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(16, context)),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Xabar'.tr,
                    labelStyle: TextStyle(
                      color: AppColors.iconColor,
                      fontSize: Responsive.scaleFont(14, context),
                    ),
                    filled: true,
                    fillColor: AppColors.iconColor.withAlpha(50),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.scaleWidth(8, context),
                      ),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: Responsive.scaleFont(14, context),
                  ),
                ),
                SizedBox(height: Responsive.scaleHeight(20, context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Bekor qilish'.tr,
                        style: TextStyle(
                          color: AppColors.textSecondaryColor,
                          fontSize: Responsive.scaleFont(14, context),
                        ),
                      ),
                    ),
                    SizedBox(width: Responsive.scaleWidth(10, context)),
                    ElevatedButton(
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          // Yordam so'rovini yuborish logikasi (masalan, API so'rovi)
                          Navigator.pop(context);
                          Get.snackbar(
                            'Muvaffaqiyatli'.tr,
                            'Yordam so\'rovi yuborildi'.tr,
                            colorText: AppColors.textColor,
                            backgroundColor: AppColors.primaryColor.withAlpha(
                              100,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Responsive.scaleWidth(8, context),
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.scaleWidth(16, context),
                          vertical: Responsive.scaleHeight(8, context),
                        ),
                      ),
                      child: Text(
                        'Yuborish'.tr,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: Responsive.scaleFont(14, context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
