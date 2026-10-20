import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

/// Ilova haqida.
class AboutAppScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScreen(
      title: 'Ilova haqida'.tr,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          // Ilova belgisi
          AppReveal(
            child: Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.onSurface.withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
                child: Icon(
                  LucideIcons.briefcaseBusiness,
                  size: 40,
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AppReveal(
            delay: const Duration(milliseconds: 70),
            child: Column(
              children: [
                Text('Ishtopchi', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  '${'Versiya'.tr} ${profileController.appVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppReveal(
            delay: const Duration(milliseconds: 130),
            child: AppTile(
              icon: LucideIcons.user,
              title: 'Ishlab chiquvchi'.tr,
              subtitle: 'Torex Dev',
              onTap: () => _launchURL('https://torexdev.uz'),
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 170),
            child: AppTile(
              icon: LucideIcons.lock,
              title: 'Ruxsatlar'.tr,
              subtitle: 'Maxfiylik siyosati va shartlar'.tr,
              onTap: () => _launchURL('https://ishtopchi.uz/uz/privacy'),
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 210),
            child: AppTile(
              icon: LucideIcons.link,
              title: 'Veb-sayt'.tr,
              subtitle: 'https://ishtopchi.uz',
              onTap: () => _launchURL('https://ishtopchi.uz'),
            ),
          ),
          const SizedBox(height: 22),
          AppReveal(
            delay: const Duration(milliseconds: 260),
            child: Text(
              '© 2025 Ishtopchi. Barcha huquqlar himoyalangan.'.tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colors.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Xatolik'.tr,
        'Havola ochilmadi'.tr,
        colorText: AppColors.white,
        backgroundColor: AppColors.red,
      );
    }
  }
}
