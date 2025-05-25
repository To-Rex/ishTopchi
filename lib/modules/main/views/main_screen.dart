import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/main_controller.dart';
import '../../favorites/views/favorites_screen.dart';
import '../../ad_posting/views/ad_posting_screen.dart';
import '../../messages/views/messages_screen.dart';
import '../../profile/views/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const MainContent(), // Asosiy sahifa uchun placeholder
    const FavoritesScreen(),
    const AdPostingScreen(),
    const MessagesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ishtopchi', style: TextStyle(color: AppColors.lightGray)),
        backgroundColor: AppColors.darkNavy,
        leading: Icon(Icons.work, color: AppColors.lightGray),
        actions: [
          IconButton(
            //icon: Icon(Icons.notifications, color: AppColors.lightGray),
            icon: Icon(LucideIcons.bell, color: AppColors.lightGray),
            onPressed: () {},
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.house), label: 'Asosiy'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.heart), label: 'Saqlanganlar'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.circlePlus), label: 'E\'lon qo\'shish'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.messageCircle), label: 'Xabarlar'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profil'),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.lightGray,
        backgroundColor: AppColors.darkNavy,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Asosiy sahifa uchun placeholder widget
class MainContent extends GetView<MainController> {
  const MainContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Asosiy sahifa (Placeholder)',
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontSize: Responsive.scaleFont(24, context),
        ),
      ),
    );
  }
}