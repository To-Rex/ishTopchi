import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../favorites/views/favorites_screen.dart';
import '../../ad_posting/views/ad_posting_screen.dart';
import '../../messages/views/messages_screen.dart';
import '../../profile/views/edit_profile_screen.dart';
import '../../profile/views/profile_screen.dart';
import 'main_content.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FuncController funcController = Get.find<FuncController>();
    final ApiController apiController = Get.find<ApiController>();
    final themeController = Get.find<ThemeController>();

    // Ilova ochilganda foydalanuvchi ma'lumotlarini yuklash
    if (funcController.globalToken.value.isNotEmpty) {
      apiController.getMe();
    }

    // Sahifalar ro'yxati
    final List<Widget> pages = [
      const MainContent(),
      const FavoritesScreen(),
      const AdPostingScreen(),
      MessagesScreen(),
      ProfileScreen(),
    ];

    return Obx(() {
      final gradientColors =
          themeController.isDarkMode.value
              ? [AppColors.darkNavy, AppColors.darkBlue]
              : [AppColors.lightBackground, AppColors.lightSurface];

      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(Responsive.scaleHeight(100, context)),
          child: Container(
            margin: EdgeInsets.only(
              top: Responsive.scaleHeight(80, context),
              left: Responsive.scaleWidth(11, context),
              right: Responsive.scaleWidth(11, context),
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => funcController.setBarIndex(0),
                  icon: Icon(
                    LucideIcons.briefcaseBusiness,
                    color: AppColors.textColor,
                    size: 24,
                  ),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Colors.transparent,
                    ),
                    elevation: WidgetStateProperty.all(0),
                    padding: WidgetStateProperty.all(EdgeInsets.all(5)),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  label: Text(
                    'Ishtopchi',
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontSize: 20.sp,
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(LucideIcons.bell, color: AppColors.textColor),
                  onPressed: () => Get.toNamed('/notifications'),
                ),
              ],
            ),
          ),
        ),
        body: Obx(
          () => IndexedStack(
            index: funcController.barIndex.value,
            children: pages,
          ),
        ),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.house),
                label: 'Asosiy'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.heart),
                label: 'Saqlanganlar'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.circlePlus),
                label: 'E’lon qo‘shish'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.messageCircle),
                label: 'Xabarlar'.tr,
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.user),
                label: 'Profil'.tr,
              ),
            ],
            selectedFontSize: Responsive.scaleFont(12, context),
            unselectedFontSize: Responsive.scaleFont(12, context),
            selectedIconTheme: IconThemeData(
              size: Responsive.scaleWidth(28, context),
            ),
            unselectedIconTheme: IconThemeData(
              size: Responsive.scaleWidth(28, context),
            ),
            currentIndex: funcController.barIndex.value,
            selectedItemColor: AppColors.selectedItem,
            unselectedItemColor: AppColors.textSecondaryColor,
            backgroundColor: AppColors.cardColor,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) {
              funcController.setBarIndex(index);
            },
          ),
        ),
      );
    });
  }
}
