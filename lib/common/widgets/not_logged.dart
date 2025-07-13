import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

class NotLogged extends StatelessWidget{
  const NotLogged({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.logIn, size: 60.sp, color: AppColors.lightGray),
        SizedBox(height: 20.sp),
        Text('Siz ro‘yhatdan o‘tmagansiz'.tr, style: TextStyle(fontSize: Responsive.scaleFont(20, context), color: AppColors.lightGray, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        SizedBox(height: 10.sp),
        Text('Iltimos, hisobingizga kiring yoki ro‘yxatdan o‘ting'.tr, style: TextStyle(fontSize: Responsive.scaleFont(16, context), color: AppColors.lightGray, fontWeight: FontWeight.w400), textAlign: TextAlign.center),
        SizedBox(height: 30.sp),
        ElevatedButton(
          onPressed: () => Get.offNamed('/login'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkBlue, // Tugma rangi
            padding: EdgeInsets.symmetric(horizontal: 40.sp, vertical: 12.sp),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp))
          ),
          child: Text('Kirish yoki Ro‘yxatdan o‘tish'.tr, style: TextStyle(fontSize: Responsive.scaleFont(16, context), color: Colors.white, fontWeight: FontWeight.w500))
        )
      ]
    )
  );
}