import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  ProfileScreen({super.key});

  final FuncController funcController = Get.put(FuncController());


  String _getProfileUrl(String? url) {
    const base = 'https://ishtopchi.uz';
    if (url == null || url.trim().isEmpty) {
      return 'https://help.tithe.ly/hc/article_attachments/18804144460951';
    }
    url = url.trim();
    return url.startsWith('http') ? url : '$base/${url.replaceAll(RegExp(r'^(file://)?/+'), '')}';
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = Responsive.scaleWidth(100, context);
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Obx(() {
        final hasToken = controller.hasToken.value;
        final user = funcController.userMe.value;
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.darkNavy,
              pinned: true,
              expandedHeight: 220,
              collapsedHeight: 70,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final isCollapsed = constraints.maxHeight <= 80;

                  return FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    title: hasToken && isCollapsed
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(radius: 16, backgroundImage: NetworkImage(_getProfileUrl(user?.data?.profilePicture))),
                        const SizedBox(width: 10),
                        Text(
                          user?.data?.firstName ?? 'no name',
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    )
                        : null,
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
                                backgroundImage: NetworkImage(_getProfileUrl(user?.data?.profilePicture)),
                              ),
                              const SizedBox(height: 12),
                              if (hasToken)
                                Column(
                                  children: [
                                    Text(user?.data?.firstName != null ? '${user!.data!.firstName} ${user.data!.lastName ?? ''}' : user?.data!.lastName != null ? user!.data!.lastName.toString() : 'no name', style: const TextStyle(color: Colors.white)),
                                    if (user?.data?.authProviders?.first.email != null)
                                      Text(
                                        user?.data?.authProviders?.first.email ?? 'no email',
                                        style: const TextStyle(color: Colors.white70),
                                      )
                                    else
                                      Text(
                                        user?.data?.authProviders?.first.providersUserId ?? 'no phone',
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                  ],
                                )
                              else
                                ElevatedButton(
                                  onPressed: controller.onLoginTap,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                                    backgroundColor: AppColors.midBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text('Kirish'.tr,
                                      style: TextStyle(color: Colors.white)),
                                ),
                            ],
                          ),
                        ),
                        if (hasToken)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: TextButton.icon(
                              onPressed: controller.onEditProfile,
                              icon: const Icon(LucideIcons.userRoundPen, color: Colors.white, size: 16),
                              label: const Text('Tahrirlash',
                                  style: TextStyle(color: Colors.white, fontSize: 13)),
                              style: TextButton.styleFrom(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    if (controller.hasToken.value)
                      _buildMenuItem(LucideIcons.userRound, 'Mening Profilim', controller.onMyPostsTap),
                    if (controller.hasToken.value)
                      _buildMenuItem(LucideIcons.squareLibrary, 'Mening Rezumelarim', controller.onMyResumesTap),
                    if (controller.hasToken.value)
                      _buildMenuItem(LucideIcons.megaphone, 'Mening e’lonlarim', controller.onMyPostsTap),
                    _buildMenuItem(LucideIcons.globe, 'Tillar', controller.onLanguagesTap, lang: true),
                    _buildMenuItem(LucideIcons.headset, 'Qo‘llab-quvvatlash', controller.onSupportTap),
                    _buildMenuItem(LucideIcons.badgeInfo, 'Ilova haqida', controller.onAboutAppTap),
                    _buildMenuItem(LucideIcons.shieldAlert, 'Xavfsizlik va Maxfiylik', controller.onPrivacyTap),
                    _buildMenuItem(LucideIcons.bell, 'Bildirishnomalar', controller.onNotificationsTap),
                    _buildMenuItem(LucideIcons.badgeHelp, 'Yordam markazi', controller.onHelpTap),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ijtimoiy tarmoqlar',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                      ),
                    ),
                    _buildMenuItem(Icons.telegram, 'Telegram', () => controller.launchUrl('https://t.me/ishtopchi')),
                    _buildMenuItem(Icons.camera_alt_outlined, 'Instagram', () => controller.launchUrl('https://instagram.com/ishtopchi')),
                    const SizedBox(height: 20),
                    if (controller.hasToken.value)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.onLogoutTap,
                          icon: const Icon(LucideIcons.logOut, color: Colors.white),
                          label: const Text('Chiqish', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade200,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
        );
      }),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {lang = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.darkBlue
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(title.tr, style: const TextStyle(color: Colors.white)),
                ),
                if (lang)
                  Text('O‘zbek', style: const TextStyle(color: Colors.white)),
                SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

