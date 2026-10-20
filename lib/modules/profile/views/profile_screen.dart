import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/funcController.dart';
import '../controllers/profile_controller.dart';

/// Profil boʻlimi: foydalanuvchi kartasi va menyu.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController controller;
  late final FuncController funcController;

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
    return Obx(() {
      if (funcController.isLoading.value &&
          funcController.getToken()!.isNotEmpty) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      return Scaffold(
        body: AppContentWidth(
          child: ListView(
            // Oxirgi qator pastki suzuvchi panel ostida qolmasin.
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              28 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              AppReveal(child: _buildIdentityCard()),
              const SizedBox(height: 20),
              if (controller.hasToken.value) ...[
                AppSectionLabel(text: 'Hisobim'.tr),
                AppReveal(
                  delay: AppReveal.step(1),
                  child: AppTile(
                    icon: LucideIcons.userRound,
                    title: 'Mening Profilim'.tr,
                    onTap: controller.onMyProfileTap,
                  ),
                ),
                AppReveal(
                  delay: AppReveal.step(2),
                  child: AppTile(
                    icon: LucideIcons.squareLibrary,
                    title: 'Mening Rezyumelarim'.tr,
                    onTap: controller.onMyResumesTap,
                  ),
                ),
                AppReveal(
                  delay: AppReveal.step(3),
                  child: AppTile(
                    icon: LucideIcons.megaphone,
                    title: 'Mening e’lonlarim'.tr,
                    onTap: controller.onMyPostsTap,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              AppSectionLabel(text: 'Ilova'.tr),
              AppReveal(
                delay: AppReveal.step(4),
                child: AppTile(
                  icon: LucideIcons.settings,
                  title: 'Sozlamalar'.tr,
                  onTap: controller.onSettingsTap,
                ),
              ),
              AppReveal(
                delay: AppReveal.step(5),
                child: AppTile(
                  icon: LucideIcons.bell,
                  title: 'Bildirishnomalar'.tr,
                  onTap: controller.onNotificationsTap,
                ),
              ),
              AppReveal(
                delay: AppReveal.step(6),
                child: AppTile(
                  icon: LucideIcons.smartphone,
                  title: 'Qurilmalar'.tr,
                  onTap: controller.onDevicesTap,
                ),
              ),
              AppReveal(
                delay: AppReveal.step(7),
                child: AppTile(
                  icon: LucideIcons.headset,
                  title: 'Qo‘llab-quvvatlash'.tr,
                  onTap: controller.onSupportTap,
                ),
              ),
              AppReveal(
                delay: AppReveal.step(8),
                child: AppTile(
                  icon: LucideIcons.badgeInfo,
                  title: 'Ilova haqida'.tr,
                  onTap: controller.onAboutAppTap,
                ),
              ),
              AppReveal(
                delay: AppReveal.step(9),
                child: AppTile(
                  icon: LucideIcons.shieldAlert,
                  title: 'Xavfsizlik va Maxfiylik'.tr,
                  onTap: controller.onPrivacyTap,
                ),
              ),
              /*AppTile(
              icon: LucideIcons.handHelping,
              title: 'Yordam markazi'.tr,
              onTap: controller.onHelpTap,
            ),*/
              const SizedBox(height: 10),
              AppSectionLabel(text: 'Ijtimoiy tarmoqlar'.tr),
              AppReveal(
                delay: AppReveal.step(10),
                child: AppTile(
                  // Lucide brend belgilarini olib tashlagan, shuning uchun
                  // FontAwesome'dagi haqiqiy belgilar ishlatiladi.
                  icon: FontAwesomeIcons.telegram.data,
                  title: 'Telegram'.tr,
                  onTap:
                      () => controller.launchExternalUrl(
                        'https://t.me/ishtopchi',
                      ),
                ),
              ),
              AppReveal(
                delay: AppReveal.step(11),
                child: AppTile(
                  icon: FontAwesomeIcons.instagram.data,
                  title: 'Instagram'.tr,
                  onTap:
                      () => controller.launchExternalUrl(
                        'https://instagram.com/ishtopchi',
                      ),
                ),
              ),
              if (controller.hasToken.value) ...[
                const SizedBox(height: 18),
                AppReveal(
                  delay: AppReveal.step(12),
                  child: AppButton(
                    label: 'Chiqish'.tr,
                    leading: const Icon(LucideIcons.logOut),
                    onPressed: controller.onLogoutTap,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Center(
                child: Text(
                  'Ishtopchi v${controller.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12.5,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Foydalanuvchi kartasi: surat, ism va hisob maʼlumoti.
  ///
  /// Avval bu 260 piksellik yigʻiladigan `SliverAppBar` edi — bir xil
  /// maʼlumot ikki marta (yigʻilgan va ochilgan holat uchun) yozilgan edi.
  Widget _buildIdentityCard() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final user = funcController.userMe.value.data;
    final loggedIn = controller.hasToken.value;

    final name =
        user?.firstName != null
            ? '${user!.firstName} ${user.lastName ?? ''}'.trim()
            : 'Ism kiritilmagan'.tr;

    final detail =
        user?.authProviders?.isNotEmpty == true
            ? user!.authProviders!.first.email ??
                user.authProviders!.first.providersUserId ??
                'Ma’lumot yo‘q'.tr
            : 'Ma’lumot yo‘q'.tr;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.onSurface.withValues(alpha: 0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child:
                loggedIn
                    ? Image.network(
                      _getProfileUrl(user?.profilePicture),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, _, _) => Icon(
                            LucideIcons.user,
                            size: 26,
                            color: colors.onSurface.withValues(alpha: 0.45),
                          ),
                    )
                    : Icon(
                      LucideIcons.user,
                      size: 26,
                      color: colors.onSurface.withValues(alpha: 0.45),
                    ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loggedIn ? name : 'Ism kiritilmagan'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  loggedIn ? detail : 'Ma’lumot yo‘q'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (!loggedIn) ...[
            const SizedBox(width: 10),
            FilledButton(
              onPressed: controller.onLoginTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: Text(
                'Kirish'.tr,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
