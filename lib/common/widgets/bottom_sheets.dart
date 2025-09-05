import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_colors.dart';

class BottomSheets {
  void showLanguageBottomSheet() {
    Get.bottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      Container(
        //padding: const EdgeInsets.all(16),
        padding: const EdgeInsets.only(bottom: 56, left: 16, right: 16, top: 16),
        decoration: const BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 100, child: Divider(height: 10, color: AppColors.lightBlue, thickness: 5, radius: BorderRadius.circular(10))),
            const SizedBox(height: 16),
            Text('Afzal ko‘rgan tilingizni tanlang'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 50),
            ListTile(
              title: const Text('O‘zbekcha', style: TextStyle(color: Colors.white)),
              trailing: Icon(size: 18, Get.locale?.languageCode == 'uz' ? LucideIcons.circleCheck : LucideIcons.circle, color: AppColors.white),
              onTap: () {
                Get.updateLocale(const Locale('uz'));
                Get.back();
              },
            ),
            Divider(color: AppColors.lightBlue, thickness: 0.8, radius: BorderRadius.circular(10)),
            ListTile(
              title: const Text('Ўзбекча', style: TextStyle(color: AppColors.white)),
              trailing: Icon(size: 18, Get.locale?.languageCode == 'oz' ? LucideIcons.circleCheck : LucideIcons.circle, color: AppColors.white),
              onTap: () {
                Get.updateLocale(const Locale('oz'));
                Get.back();
              }
            ),
            Divider(color: AppColors.lightBlue, thickness: 0.8, radius: BorderRadius.circular(10)),
            ListTile(
              title: const Text('Русский', style: TextStyle(color: Colors.white)),
              trailing: Icon(size: 18, Get.locale?.languageCode == 'ru' ? LucideIcons.circleCheck : LucideIcons.circle, color: Colors.white),
              onTap: () {
                Get.updateLocale(const Locale('ru'));
                Get.back();
              }
            ),
            Divider(color: AppColors.lightBlue, thickness: 0.8, radius: BorderRadius.circular(10)),
            ListTile(
              title: const Text('English', style: TextStyle(color: Colors.white)),
              trailing: Icon(size: 18, Get.locale?.languageCode == 'en' ? LucideIcons.circleCheck : LucideIcons.circle, color: Colors.white),
              onTap: () {
                Get.updateLocale(const Locale('en'));
                Get.back();
              }
            ),
            //const SizedBox(height: 50)
          ]
        )
      )
    );
  }
}