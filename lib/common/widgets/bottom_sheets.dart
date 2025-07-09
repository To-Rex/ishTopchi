import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_colors.dart';


class BottomSheets {
  void showLanguageBottomSheet() {
    Get.bottomSheet(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
      Container(
        padding: const EdgeInsets.all(16),
       // height: Get.height * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              child: Divider(height: 10, color: AppColors.lightBlue, thickness: 5, radius: BorderRadius.circular(10)),
            ),
            SizedBox(height: 16),
            const Text('Afzal ko‘rgan tilingizni tanlang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            //Spacer(),
            SizedBox(height: 50),
            ListTile(
              title: const Text('O‘zbekcha', style: TextStyle(color: Colors.white)),
              trailing: const Icon(size: 18, LucideIcons.circleCheck, color: AppColors.white),
              onTap: () {
                Get.updateLocale(Locale('uz'));
              }
            ),
            //Divider(color: AppColors.lightBlue, thickness: 0.8, radius: BorderRadius.circular(10)),
            ListTile(
              title: const Text('Ўзбекча', style: TextStyle(color: AppColors.white)),
              trailing: const Icon(size: 18, LucideIcons.circle, color: AppColors.white),
              onTap: () {
                Get.updateLocale(Locale('oz'));
              }
            ),
            //Divider(color: AppColors.lightBlue, thickness: 0.8, radius: BorderRadius.circular(10)),
            ListTile(
              title: const Text('Русский', style: TextStyle(color: Colors.white)),
              trailing: const Icon(size: 18, LucideIcons.circle, color: Colors.white),
              onTap: () {
                Get.updateLocale(Locale('ru'));
              }
            ),
            //Divider(color: AppColors.lightBlue, thickness: 0.8, radius: BorderRadius.circular(10)),
            ListTile(
              title: const Text('English', style: TextStyle(color: Colors.white)),
              trailing: const Icon(size: 18, LucideIcons.circle, color: Colors.white),
              onTap: () {
                Get.updateLocale(Locale('en'));
              }
            ),
            SizedBox(height: 50),
            //Spacer()
          ]
        )
      )
    );
  }
}