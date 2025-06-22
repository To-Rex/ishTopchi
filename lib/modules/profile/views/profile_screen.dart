import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double avatarSize = Responsive.scaleWidth(100, context);

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.darkNavy,
            pinned: true,
            expandedHeight: 220,
            collapsedHeight: 70,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final isCollapsed = constraints.maxHeight <= 80;
                return Obx(() => FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: isCollapsed
                      ? Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(controller.userMe.value?.profilePicture ?? 'https://help.tithe.ly/hc/article_attachments/18804144460951'),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        controller.userMe.value?.firstName ?? 'no name',
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ) : null,
                  background: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                                radius: avatarSize / 2,
                                backgroundImage: NetworkImage(controller.userMe.value?.profilePicture ?? 'https://help.tithe.ly/hc/article_attachments/18804144460951')
                            ),
                            const SizedBox(height: 12),
                            Obx(() => Text(
                                controller.userMe.value?.firstName ?? 'no name',
                                style: const TextStyle(color: Colors.white))),
                            Obx(() => Text(
                              //controller.email.value,
                                controller.userMe.value?.authProviders?.first.email ?? 'no email',
                                style: const TextStyle(color: Colors.white70))),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: TextButton.icon(
                          onPressed: controller.onEditProfile,
                          icon: const Icon(Icons.edit, color: Colors.white, size: 16),
                          label: const Text('Tahrirlash',
                              style: TextStyle(color: Colors.white, fontSize: 13)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildMenuItem(Icons.list_alt, 'Mening e’lonlarim', controller.onMyPostsTap),
                  _buildMenuItem(Icons.language, 'Tillar', controller.onLanguagesTap),
                  _buildMenuItem(Icons.support_agent, 'Qo‘llab-quvvatlash', controller.onSupportTap),
                  _buildMenuItem(Icons.info_outline, 'Ilova haqida', controller.onAboutAppTap),
                  _buildMenuItem(Icons.privacy_tip, 'Xavfsizlik va Maxfiylik', controller.onPrivacyTap),
                  _buildMenuItem(Icons.notifications_none, 'Bildirishnomalar', controller.onNotificationsTap),
                  _buildMenuItem(Icons.help_outline, 'Yordam markazi', controller.onHelpTap),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ijtimoiy tarmoqlar',
                      style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _buildMenuItem(Icons.telegram, 'Telegram',
                          () => controller.launchUrl('https://t.me/ishtopchi')),
                  _buildMenuItem(Icons.camera_alt_outlined, 'Instagram',
                          () => controller.launchUrl('https://instagram.com/ishtopchi')),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.onLogoutTap,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text('Chiqish', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade200,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Ishtopchi v1.0',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6),
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white60),
      onTap: onTap,
    );
  }
}