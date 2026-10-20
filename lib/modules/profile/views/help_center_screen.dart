import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_theme.dart';
import '../controllers/profile_controller.dart';

/// Yordam markazi.
///
/// Savol-javoblar endi yigʻiladi: javob bosilganda yumshoq ochiladi.
/// Avval barcha javoblar bir vaqtda koʻrinib, ekran uzun boʻlib ketardi.
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  HelpCenterScreenState createState() => HelpCenterScreenState();
}

class HelpCenterScreenState extends State<HelpCenterScreen> {
  final ProfileController profileController = Get.find<ProfileController>();

  /// Savol-javoblar.
  late final List<({String question, String answer})> _faq = [
    (
      question: 'Qanday qilib ro‘yxatdan o‘taman?'.tr,
      answer:
          'Ro‘yxatdan o‘tish uchun "Kirish" tugmasini bosing va ko‘rsatmalarni bajaring.'
              .tr,
    ),
    (
      question: 'Parolni qanday tiklayman?'.tr,
      answer:
          'Siz "Parolni unutdingizmi?" havolasini ishlatib parolni tiklashingiz mumkin.'
              .tr,
    ),
    (
      question: 'Ilovada xatolik yuz berdi, nima qilish kerak?'.tr,
      answer:
          'Iltimos, ilova versiyasini yangilab ko‘ring yoki Qo‘llab-quvvatlashga murojaat qiling.'
              .tr,
    ),
  ];

  /// Qoʻllanmalar.
  late final List<({String title, String url})> _guides = [
    (title: 'Ilova bilan tanishish'.tr, url: 'https://ishtopchi.uz/guide'),
    (
      title: 'Xususiyatlarni foydalanish'.tr,
      url: 'https://ishtopchi.uz/features',
    ),
    (
      title: 'Profilni sozlamoqchimisiz?'.tr,
      url: 'https://ishtopchi.uz/profile-setup',
    ),
  ];

  /// Bogʻlanish usullari.
  late final List<({IconData icon, String title, String value, String url})>
  _contacts = [
    (
      icon: LucideIcons.phone,
      title: 'Telefon'.tr,
      value: '+998 77 050 01 25',
      url: 'tel:+998770500125',
    ),
    (
      icon: LucideIcons.mail,
      title: 'Email'.tr,
      value: 'ishtopchi@gmail.com',
      url: 'mailto:ishtopchi@gmail.com',
    ),
    (
      icon: LucideIcons.send,
      title: 'Telegram'.tr,
      value: '@Ishtopchi_uz',
      url: 'https://t.me/Ishtopchi_uz',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    var step = 0;

    return AppScreen(
      title: 'Yordam markazi'.tr,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          AppReveal(delay: AppReveal.step(step++), child: _buildWelcome()),
          const SizedBox(height: 20),
          AppSectionLabel(text: 'Tez-tez so‘raladigan savollar'.tr),
          for (final item in _faq)
            AppReveal(
              delay: AppReveal.step(step++),
              child: _FaqTile(question: item.question, answer: item.answer),
            ),
          const SizedBox(height: 16),
          AppSectionLabel(text: 'Qo‘llanmalar'.tr),
          for (final guide in _guides)
            AppReveal(
              delay: AppReveal.step(step++),
              child: AppTile(
                icon: LucideIcons.bookOpen,
                title: guide.title,
                subtitle: guide.url,
                onTap: () => _launchURL(guide.url),
              ),
            ),
          const SizedBox(height: 16),
          AppSectionLabel(text: 'Biz bilan bog‘lanish'.tr),
          for (final contact in _contacts)
            AppReveal(
              delay: AppReveal.step(step++),
              child: AppTile(
                icon: contact.icon,
                title: contact.title,
                subtitle: contact.value,
                onTap: () => _launchURL(contact.url),
              ),
            ),
          const SizedBox(height: 18),
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

  Widget _buildWelcome() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'help-icon',
            child: Icon(
              LucideIcons.circleHelp,
              color: colors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xush kelibsiz!'.tr, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Bu yerda siz ilova bilan ishlash bo‘yicha yordam topasiz. Savollaringiz uchun biz bilan bog‘laning.'
                      .tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12.5,
                    color: colors.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
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

/// Yigʻiladigan savol-javob.
class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _open = !_open),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color:
                    _open
                        ? colors.primary.withValues(alpha: 0.30)
                        : colors.onSurface.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 10),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                // Javob yumshoq ochiladi.
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topLeft,
                  child:
                      _open
                          ? Padding(
                            padding: const EdgeInsets.only(top: 10, right: 30),
                            child: Text(
                              widget.answer,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: colors.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          )
                          : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
