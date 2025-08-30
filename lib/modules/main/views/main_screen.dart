import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ishtopchi', style: TextStyle(color: AppColors.lightGray)),
        backgroundColor: AppColors.darkNavy,
        leading: const Icon(LucideIcons.briefcaseBusiness, color: AppColors.lightGray),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: AppColors.lightGray),
            onPressed: () => Get.toNamed('/notifications'),
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: funcController.barIndex.value,
        children: pages,
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.house), label: 'Asosiy'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.heart), label: 'Saqlanganlar'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.circlePlus), label: 'E’lon qo‘shish'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.messageCircle), label: 'Xabarlar'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profil'),
        ],
        selectedFontSize: Responsive.scaleFont(12, context),
        unselectedFontSize: Responsive.scaleFont(12, context),
        selectedIconTheme: IconThemeData(size: Responsive.scaleWidth(28, context)),
        unselectedIconTheme: IconThemeData(size: Responsive.scaleWidth(28, context)),
        currentIndex: funcController.barIndex.value,
        selectedItemColor: AppColors.selectedItem,
        unselectedItemColor: AppColors.lightGray,
        backgroundColor: AppColors.darkNavy,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (index) {
          funcController.setBarIndex(index);
        }
      ))
    );
  }
}