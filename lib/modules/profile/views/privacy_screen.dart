import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

/// Xavfsizlik va maxfiylik.
class PrivacyScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AppScreen(
      title: 'Xavfsizlik va Maxfiylik'.tr,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          // Maxfiylik siyosati
          AppReveal(
            child: _Section(
              title: 'Maxfiylik Siyosati'.tr,
              body:
                  'Sizning shaxsiy ma’lumotlaringiz xavfsiz saqlanadi. Ma’lumotlaringizni ko‘rish va boshqarish uchun quyidagi havolaga o‘ting.'
                      .tr,
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 60),
            child: AppTile(
              icon: LucideIcons.link,
              title: 'Maxfiylik siyosati'.tr,
              subtitle: 'ishtopchi.uz',
              onTap: () => _launchURL('https://ishtopchi.uz/uz/privacy'),
            ),
          ),
          const SizedBox(height: 14),
          // Ma'lumotlar xavfsizligi
          AppReveal(
            delay: const Duration(milliseconds: 110),
            child: _Section(
              title: 'Ma’lumotlar Xavfsizligi'.tr,
              body:
                  'Biz eng zamonaviy shifrlash usullaridan foydalanamiz. Ma’lumotlaringiz faqat ruxsat berilgan holatda ishlatiladi.'
                      .tr,
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 160),
            child: AppTile(
              icon: LucideIcons.shieldCheck,
              title: 'Xavfsizlik qoidalari'.tr,
              subtitle: 'ishtopchi.uz',
              onTap: () => _launchURL('https://ishtopchi.uz/uz/data-security'),
            ),
          ),
          const SizedBox(height: 14),
          // Sozlamalar
          AppReveal(
            delay: const Duration(milliseconds: 210),
            child: _Section(
              title: 'Maxfiylik Sozlamalari'.tr,
              body:
                  'Shaxsiy ma’lumotlaringizni boshqarish uchun sozlamalarni tekshiring.'
                      .tr,
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 260),
            child: AppTile(
              icon: LucideIcons.settings,
              title: 'Maxfiylik sozlamalarini ko‘rish'.tr,
              onTap: _openSettings,
            ),
          ),
          const SizedBox(height: 20),
          // Mualliflik
          Text(
            '© 2025 Ishtopchi. Barcha huquqlar himoyalangan.'.tr,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: colors.onSurface.withValues(alpha: 0.45),
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

  void _openSettings() {
    // Bu yerda maxfiylik sozlamalarini ochish uchun maxsus ekran yoki navigatsiya qo'shilishi mumkin
    Get.snackbar(
      'Xabar'.tr,
      'Maxfiylik sozlamalari hozircha mavjud emas'.tr,
      colorText: AppColors.textColor,
      backgroundColor: AppColors.secondaryColor.withAlpha(100),
    );
  }
}

/// Sarlavha va uning ostidagi izoh matni.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
