import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  // Bildirishnoma sozlamalari uchun holatlar
  bool isGeneralEnabled = true;
  bool isMessagesEnabled = true;
  bool isRemindersEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirishnomalar', style: TextStyle(color: AppColors.lightGray, fontSize: Responsive.scaleFont(18, context))),
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
            // Umumiy bildirishnomalar
            _buildSettingItem(context, 'Umumiy bildirishnomalar', isGeneralEnabled, (value) {
              setState(() {
                isGeneralEnabled = value;
              });
            }),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            // Xabarlar bildirishnomalari
            _buildSettingItem(context, 'Xabarlar', isMessagesEnabled, (value) {
              setState(() {
                isMessagesEnabled = value;
              });
            }),
            SizedBox(height: Responsive.scaleHeight(12, context)),
            // Eslatmalar bildirishnomalari
            _buildSettingItem(context, 'Eslatmalar', isRemindersEnabled, (value) {
              setState(() {
                isRemindersEnabled = value;
              });
            }),
            SizedBox(height: Responsive.scaleHeight(24, context)),
            // Saqlash tugmasi
            Center(
              child: ElevatedButton(
                onPressed: () => _saveSettings(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Responsive.scaleWidth(15, context))),
                  padding: EdgeInsets.symmetric(vertical: Responsive.scaleHeight(12, context), horizontal: Responsive.scaleWidth(40, context)),
                  elevation: 2,
                ),
                child: Text(
                  'Sozlamalarni saqlash',
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

  Widget _buildSettingItem(BuildContext context, String title, bool value, Function(bool) onChanged) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: Responsive.scaleFont(14, context),
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.lightBlue,
            inactiveThumbColor: AppColors.lightGray,
            inactiveTrackColor: AppColors.darkBlue.withAlpha(50),
          ),
        ],
      ),
    );
  }

  void _saveSettings(BuildContext context) {
    // Saqlash logikasi (masalan, backend ga yuborish)
    Get.snackbar(
      'Muvaffaqiyat',
      'Bildirishnoma sozlamalari saqlandi',
      colorText: AppColors.white,
      backgroundColor: AppColors.lightBlue.withAlpha(100),
    );
    Get.back();
  }
}