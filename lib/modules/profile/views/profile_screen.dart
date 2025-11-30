import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  ProfileScreen({super.key});

  final FuncController funcController = Get.find<FuncController>();

  String _getProfileUrl(String? url) {
    const base = 'https://ishtopchi.uz';
    const defaultImage = 'https://help.tithe.ly/hc/article_attachments/18804144460951';
    if (url == null || url.trim().isEmpty) {
      return defaultImage;
    }
    url = url.trim();
    if (!url.startsWith('http')) {
      url = '$base/${url.replaceAll(RegExp(r'^(file://)?/+'), '')}';
    }
    return Uri.parse(url).isAbsolute ? url : defaultImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Obx(() {
        if (funcController.isLoading.value && funcController.getToken()!.isNotEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.lightBlue));
        }
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
                    title: funcController.globalToken.value.isNotEmpty && isCollapsed ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(radius: 16, backgroundImage: NetworkImage(_getProfileUrl(funcController.userMe.value.data?.profilePicture))),
                        const SizedBox(width: 10),
                        Text(funcController.userMe.value.data?.firstName ?? 'Ism kiritilmagan'.tr, style: TextStyle(fontSize: Responsive.scaleFont(14, context), color: Colors.white))
                      ]
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
                              if (funcController.globalToken.value.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(1000),
                                child: SizedBox(
                                  height: Responsive.scaleHeight(140, context),
                                  width: Responsive.scaleWidth(140, context),
                                  child: CachedNetworkImage(
                                    imageUrl: _getProfileUrl(funcController.userMe.value.data?.profilePicture),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.lightBlue, strokeWidth: 2)),
                                    errorWidget: (context, url, error) => Container(
                                      height: Responsive.scaleHeight(140, context),
                                      width: Responsive.scaleWidth(140, context),
                                      decoration: BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.circular(1000)),
                                      child: Center(child: Icon(LucideIcons.imageOff, size: Responsive.scaleFont(48, context), color: AppColors.lightGray))
                                    )
                                  )
                                )
                              ) else
                                Container(
                                  height: Responsive.scaleHeight(140, context),
                                  width: Responsive.scaleWidth(140, context),
                                  decoration: BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.circular(1000)),
                                  child: Center(child: Icon(LucideIcons.userRoundX, size: Responsive.scaleFont(48, context), color: AppColors.red))
                                ),
                              const SizedBox(height: 12),
                              if (funcController.globalToken.value.isNotEmpty)
                                Column(
                                  children: [
                                    Text(
                                      funcController.userMe.value.data?.firstName != null
                                          ? '${funcController.userMe.value.data!.firstName} ${funcController.userMe.value.data?.lastName ?? ''}'
                                          : funcController.userMe.value.data?.lastName ?? 'Ism kiritilmagan'.tr,
                                      style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(18, context), fontWeight: FontWeight.w500)
                                    ),
                                    Text(
                                      funcController.userMe.value.data?.authProviders?.isNotEmpty == true
                                          ? funcController.userMe.value.data!.authProviders!.first.email ?? funcController.userMe.value.data!.authProviders!.first.providersUserId ?? 'Ma’lumotlar yo‘q'.tr
                                          : 'Ma’lumotlar yo‘q'.tr,
                                      style: TextStyle(color: AppColors.lightGray.withAlpha(200), fontSize: Responsive.scaleFont(18, context))
                                    )
                                  ]
                                )
                              else
                                ElevatedButton(
                                  onPressed: controller.onLoginTap,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(200, 40),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                                    backgroundColor: AppColors.midBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                  ),
                                  child: Text('Kirish'.tr, style: const TextStyle(color: Colors.white)),
                                )
                            ]
                          )
                        ),
                        if (funcController.globalToken.value.isNotEmpty)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: TextButton.icon(
                              onPressed: controller.onEditProfile,
                              icon: const Icon(LucideIcons.userRoundPen, color: Colors.white, size: 16),
                              label: Text('Tahrirlash'.tr, style: TextStyle(color: Colors.white, fontSize: 13)),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4))
                            )
                          )
                      ]
                    )
                  );
                }
              )
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    if (controller.hasToken.value) _buildMenuItem(LucideIcons.userRound, 'Mening Profilim'.tr, controller.onMyProfileTap),
                    if (controller.hasToken.value) _buildMenuItem(LucideIcons.squareLibrary, 'Mening Rezyumelarim'.tr, controller.onMyResumesTap),
                    if (controller.hasToken.value) _buildMenuItem(LucideIcons.megaphone, 'Mening e’lonlarim', controller.onMyPostsTap),
                    _buildMenuItem(LucideIcons.globe, 'Tillar'.tr, controller.onLanguagesTap, lang: true),
                    _buildMenuItem(LucideIcons.smartphone, 'Qurilmalar'.tr, controller.onDevicesTap),
                    _buildMenuItem(LucideIcons.headset, 'Qo‘llab-quvvatlash'.tr, controller.onSupportTap),
                    _buildMenuItem(LucideIcons.badgeInfo, 'Ilova haqida'.tr, controller.onAboutAppTap),
                    _buildMenuItem(LucideIcons.shieldAlert, 'Xavfsizlik va Maxfiylik'.tr, controller.onPrivacyTap),
                    _buildMenuItem(LucideIcons.bell, 'Bildirishnomalar'.tr, controller.onNotificationsTap),
                    _buildMenuItem(LucideIcons.handHelping, 'Yordam markazi'.tr, controller.onHelpTap),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Ijtimoiy tarmoqlar'.tr, style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                    ),
                    _buildMenuItem(Icons.telegram, 'Telegram'.tr, () => controller.launchUrl('https://t.me/ishtopchi')),
                    _buildMenuItem(Icons.camera_alt_outlined, 'Instagram'.tr, () => controller.launchUrl('https://instagram.com/ishtopchi')),
                    const SizedBox(height: 20),
                    if (controller.hasToken.value)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.onLogoutTap,
                          icon: const Icon(LucideIcons.logOut, color: Colors.white),
                          label: Text('Chiqish'.tr, style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade200,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          )
                        )
                      ),
                    const SizedBox(height: 24),
                    Center(child: Text('Ishtopchi v1.1', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)))
                  ]
                )
              )
            )
          ]
        );
      })
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool lang = false}) {
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.darkBlue),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(child: Text(title.tr, style: const TextStyle(color: Colors.white))),
                if (lang) Text('O‘zbek'.tr, style: TextStyle(color: Colors.white)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}