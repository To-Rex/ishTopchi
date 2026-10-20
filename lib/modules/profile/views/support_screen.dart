import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

/// Qoʻllab-quvvatlash.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Qo‘llab-quvvatlash'.tr,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          AppSectionLabel(text: 'Bog‘lanish'.tr),
          AppReveal(
            child: AppTile(
              icon: LucideIcons.phone,
              title: 'Telefon'.tr,
              subtitle: '+998 77 050 01 25',
              onTap: () => _launchURL('tel:+998770500125'),
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 60),
            child: AppTile(
              icon: LucideIcons.mail,
              title: 'Email'.tr,
              subtitle: 'support@ishtopchi.uz',
              onTap: () => _launchURL('mailto:support@ishtopchi.uz'),
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 110),
            child: AppTile(
              icon: LucideIcons.send,
              title: 'Telegram'.tr,
              subtitle: '@IshtopchiSupport',
              onTap: () => _launchURL('https://t.me/IshtopchiSupport'),
            ),
          ),
          const SizedBox(height: 16),
          AppSectionLabel(text: 'Yordam markazi'.tr),
          AppReveal(
            delay: const Duration(milliseconds: 160),
            child: AppTile(
              icon: LucideIcons.circleHelp,
              title: 'Ko‘p beriladigan savollar'.tr,
              onTap: () => _launchURL('https://ishtopchi.uz/faq'),
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 200),
            child: AppTile(
              icon: LucideIcons.bookOpen,
              title: 'Qo‘llanma'.tr,
              onTap: () => _launchURL('https://ishtopchi.uz/guide'),
            ),
          ),
          const SizedBox(height: 22),
          AppReveal(
            delay: const Duration(milliseconds: 250),
            child: AppButton(
              label: 'Yordam so‘rash'.tr,
              leading: const Icon(LucideIcons.messageSquarePlus),
              filled: true,
              onPressed: () => _showSupportRequestDialog(context),
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

  void _showSupportRequestDialog(BuildContext context) {
    final TextEditingController messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yordam so‘rash'.tr, style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(labelText: 'Xabar'.tr),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Bekor qilish'.tr),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        if (messageController.text.isNotEmpty) {
                          // Yordam so'rovini yuborish logikasi (masalan, API so'rovi)
                          Navigator.pop(context);
                          Get.snackbar(
                            'Muvaffaqiyatli'.tr,
                            'Yordam so‘rovi yuborildi'.tr,
                            colorText: AppColors.textColor,
                            backgroundColor: AppColors.primaryColor.withAlpha(
                              100,
                            ),
                          );
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusControl,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                      ),
                      child: Text('Yuborish'.tr),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
