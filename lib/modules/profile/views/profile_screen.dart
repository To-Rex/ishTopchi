import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/responsive.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late final ProfileController controller;
  late final FuncController funcController;

  double _buttonScale = 1.0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
    funcController = Get.find<FuncController>();
  }

  String _getProfileUrl(String? url) {
    const base = 'https://ishtopchi.uz';
    const defaultImage =
        'https://help.tithe.ly/hc/article_attachments/18804144460951';
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
              expandedHeight: 260,
              collapsedHeight: 60,
              foregroundColor: Colors.white,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final isCollapsed = constraints.maxHeight <= 80;
                  return FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: EdgeInsets.symmetric(horizontal: 20.sp),
                    collapseMode: CollapseMode.pin,
                    stretchModes: [StretchMode.zoomBackground, StretchMode.blurBackground, StretchMode.fadeTitle],
                    title: isCollapsed
                        ? funcController.globalToken.value.isNotEmpty
                        ? Center(child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(radius: 16, backgroundImage: NetworkImage(_getProfileUrl(funcController.userMe.value.data?.profilePicture))),
                              const SizedBox(width: 10),
                              Text(funcController.userMe.value.data?.firstName ?? 'Ism kiritilmagan'.tr, style: TextStyle(fontSize: Responsive.scaleFont(14, context), color: Colors.white)),
                              Spacer()
                            ]))
                        : Center(child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.userPlus, size: 24.sp, color: Colors.white),
                              SizedBox(width: 10.w),
                              Text('Ro‘yxatdan o‘ting va boshlang!'.tr, style: TextStyle(fontSize: Responsive.scaleFont(14, context), color: Colors.white)),
                              Spacer(),
                              _buildLoginButton()
                            ]
                      ))
                        : null,
                    background: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(top: 10, right: 16, left: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (funcController.globalToken.value.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(1000),
                                  child: SizedBox(
                                    height: Responsive.scaleHeight(130, context),
                                    width: Responsive.scaleWidth(130, context),
                                    child: CachedNetworkImage(
                                      imageUrl: _getProfileUrl(funcController.userMe.value.data?.profilePicture),
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.lightBlue, strokeWidth: 2)),
                                      errorWidget: (context, url, error) => Container(
                                            height: Responsive.scaleHeight(130, context),
                                            width: Responsive.scaleWidth(130, context),
                                            decoration: BoxDecoration(color: AppColors.darkBlue, borderRadius: BorderRadius.circular(1000)),
                                            child: Center(child: Icon(LucideIcons.imageOff, size: Responsive.scaleFont(48, context), color: AppColors.lightGray))
                                          )
                                    )
                                  )
                                )
                              else
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  duration: const Duration(milliseconds: 500),
                                  builder:
                                      (context, opacity, child) => Opacity(
                                        opacity: opacity,
                                        child: Container(
                                          width: Responsive.scaleWidth(500, context),
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(colors: [AppColors.midBlue, AppColors.lightBlue], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                            borderRadius: BorderRadius.circular(16.r),
                                            boxShadow: [BoxShadow(color: AppColors.midBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))]
                                          ),
                                          child: Column(
                                            children: [
                                              TweenAnimationBuilder<double>(
                                                tween: Tween(begin: 0.8, end: 1.0),
                                                duration: const Duration(milliseconds: 1000),
                                                curve: Curves.bounceOut,
                                                builder: (context, scale, child) => Transform.scale(scale: scale, child: Icon(LucideIcons.userPlus, size: Responsive.scaleFont(60, context), color: Colors.white))
                                              ),
                                              const SizedBox(height: 16),
                                              Text('Ro‘yxatdan o‘ting va boshlang!'.tr, style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w500), textAlign: TextAlign.center),
                                              const SizedBox(height: 20),
                                              GestureDetector(
                                                onTapDown: (_) => setState(() => _buttonScale = 0.95),
                                                onTapUp: (_) => setState(() => _buttonScale = 1.0),
                                                onTapCancel: () => setState(() => _buttonScale = 1.0),
                                                onTap: controller.onLoginTap,
                                                child: AnimatedScale(
                                                  scale: _buttonScale,
                                                  duration: const Duration(milliseconds: 100),
                                                  child: ElevatedButton(
                                                    onPressed: controller.onLoginTap,
                                                    // Handled by GestureDetector
                                                    style: ElevatedButton.styleFrom(
                                                      minimumSize: Size(Responsive.scaleWidth(200, context), 50),
                                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                      backgroundColor: AppColors.darkNavy,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                      elevation: 5),
                                                    child: Text('Kirish'.tr, style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w600))
                                                  )
                                                )
                                              )
                                            ]
                                          )
                                        )
                                      )
                                ),
                              const SizedBox(height: 8),
                              if (funcController.globalToken.value.isNotEmpty)
                                Column(
                                  children: [
                                    Text(
                                      funcController.userMe.value.data?.firstName != null ? '${funcController.userMe.value.data!.firstName} ${funcController.userMe.value.data?.lastName ?? ''}' : funcController.userMe.value.data?.lastName ?? 'Ism kiritilmagan'.tr,
                                      style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(16, context), fontWeight: FontWeight.w500)
                                    ),
                                    Text(
                                      funcController.userMe.value.data?.authProviders?.isNotEmpty == true ? funcController.userMe.value.data!.authProviders!.first.email ?? funcController.userMe.value.data!.authProviders!.first.providersUserId ?? 'Ma’lumotlar yo‘q'.tr : 'Ma’lumotlar yo‘q'.tr,
                                      style: TextStyle(color: AppColors.lightGray.withAlpha(200), fontSize: Responsive.scaleFont(16, context))
                                    )
                                  ]
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
                padding: EdgeInsets.only(top: 10, left: 16.w, right: 16.w, bottom: 150.h),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    if (controller.hasToken.value)
                      _buildMenuItem(
                        LucideIcons.userRound,
                        'Mening Profilim'.tr,
                        controller.onMyProfileTap,
                      ),
                    if (controller.hasToken.value)
                      _buildMenuItem(
                        LucideIcons.squareLibrary,
                        'Mening Rezyumelarim'.tr,
                        controller.onMyResumesTap,
                      ),
                    if (controller.hasToken.value)
                      _buildMenuItem(
                        LucideIcons.megaphone,
                        'Mening e’lonlarim',
                        controller.onMyPostsTap,
                      ),
                    _buildMenuItem(
                      LucideIcons.globe,
                      'Tillar'.tr,
                      controller.onLanguagesTap,
                      lang: true,
                    ),
                    _buildMenuItem(
                      LucideIcons.smartphone,
                      'Qurilmalar'.tr,
                      controller.onDevicesTap,
                    ),
                    _buildMenuItem(
                      LucideIcons.headset,
                      'Qo‘llab-quvvatlash'.tr,
                      controller.onSupportTap,
                    ),
                    _buildMenuItem(
                      LucideIcons.badgeInfo,
                      'Ilova haqida'.tr,
                      controller.onAboutAppTap,
                    ),
                    _buildMenuItem(
                      LucideIcons.shieldAlert,
                      'Xavfsizlik va Maxfiylik'.tr,
                      controller.onPrivacyTap,
                    ),
                    _buildMenuItem(
                      LucideIcons.bell,
                      'Bildirishnomalar'.tr,
                      controller.onNotificationsTap,
                    ),
                    _buildMenuItem(
                      LucideIcons.handHelping,
                      'Yordam markazi'.tr,
                      controller.onHelpTap,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ijtimoiy tarmoqlar'.tr,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildMenuItem(
                      Icons.telegram,
                      'Telegram'.tr,
                      () => controller.launchUrl('https://t.me/ishtopchi'),
                    ),
                    _buildMenuItem(
                      Icons.camera_alt_outlined,
                      'Instagram'.tr,
                      () => controller.launchUrl(
                        'https://instagram.com/ishtopchi',
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (controller.hasToken.value)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.onLogoutTap,
                          icon: const Icon(
                            LucideIcons.logOut,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Chiqish'.tr,
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.shade200,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
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

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: controller.onLoginTap,
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkNavy, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
      child: Text('Kirish'.tr, style: TextStyle(color: Colors.white, fontSize: Responsive.scaleFont(14, context), fontWeight: FontWeight.w600))
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
                if (lang)Text('O‘zbek'.tr, style: TextStyle(color: Colors.white)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white60)
              ]
            )
          )
        )
      )
    );
  }
}
