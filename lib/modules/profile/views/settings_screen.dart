import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ishtopchi/modules/profile/controllers/profile_controller.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/theme_controller.dart';

/// Ilova sozlamalari.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GetStorage storage = GetStorage();
  late ThemeController themeController;
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'uz';

  /// Tanlanadigan tillar.
  static const Map<String, String> _languages = {
    'uz': 'O‘zbek',
    'ru': 'Русский',
    'en': 'English',
  };

  @override
  void initState() {
    super.initState();
    themeController = Get.find<ThemeController>();
    _loadSettings();
  }

  void _loadSettings() {
    final language = storage.read('language') ?? 'uz';
    setState(() {
      _notificationsEnabled = storage.read('notifications_enabled') ?? true;
      _selectedLanguage = language;
    });

    // Update locale after build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(Locale(language));
    });
  }

  void _saveSetting(String key, bool value) {
    storage.write(key, value);
  }

  void _saveLanguage(String language) {
    storage.write('language', language);
    setState(() {
      _selectedLanguage = language;
    });
    // Update locale after build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.updateLocale(Locale(language));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      title: 'Sozlamalar'.tr,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
        children: [
          AppSectionLabel(text: 'Umumiy'.tr),
          AppReveal(
            child: AppTile(
              icon: LucideIcons.globe,
              title: 'Tillar'.tr,
              subtitle: 'Ilova tilini tanlang'.tr,
              trailing: _LanguagePicker(
                selected: _selectedLanguage,
                languages: _languages,
                onChanged: _saveLanguage,
              ),
            ),
          ),
          AppReveal(
            delay: const Duration(milliseconds: 60),
            child: AppTile(
              icon: LucideIcons.bell,
              title: 'Bildirishnomalar'.tr,
              subtitle: 'Bildirishnomalarni yoqish-o‘chirish'.tr,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSetting('notifications_enabled', value);
                },
              ),
            ),
          ),
          GetX<ThemeController>(
            builder: (controller) {
              return AppReveal(
                delay: const Duration(milliseconds: 110),
                child: AppTile(
                  icon: LucideIcons.moon,
                  title: 'Qorong‘i rejim'.tr,
                  subtitle: 'Ilova dizaynini o‘zgartirish'.tr,
                  trailing: Switch(
                    value: controller.isDarkMode.value,
                    onChanged: (value) => controller.toggleTheme(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          AppSectionLabel(text: 'Boshqa'.tr),
          AppReveal(
            delay: const Duration(milliseconds: 170),
            child: AppTile(
              icon: LucideIcons.info,
              title: 'Versiya ma’lumotlari'.tr,
              subtitle: 'Ilova versiyasi va yangilanishlar'.tr,
              onTap: _showVersionInfo,
            ),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo() {
    final theme = Theme.of(context);

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Versiya ma’lumotlari'.tr,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              _VersionCard(
                icon: LucideIcons.smartphone,
                label: 'Ilova versiyasi'.tr,
                value: ProfileController().appVersion,
              ),
              const SizedBox(height: 10),
              _VersionCard(
                icon: LucideIcons.monitor,
                label: 'Qurilma'.tr,
                value: 'Android / iOS',
              ),
              const SizedBox(height: 10),
              _VersionCard(
                icon: LucideIcons.code,
                label: 'Build'.tr,
                value: '2025.01.10',
              ),
              const SizedBox(height: 20),
              // Close Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Get.back(),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusControl,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text('Yopish'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Til tanlash tugmasi.
class _LanguagePicker extends StatelessWidget {
  const _LanguagePicker({
    required this.selected,
    required this.languages,
    required this.onChanged,
  });

  final String selected;
  final Map<String, String> languages;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selected,
        isDense: true,
        borderRadius: BorderRadius.circular(14),
        dropdownColor: theme.cardTheme.color ?? colors.surfaceContainer,
        icon: Icon(
          LucideIcons.chevronDown,
          size: 16,
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
        items:
            languages.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

/// Versiya oynasidagi bitta qator.
class _VersionCard extends StatelessWidget {
  const _VersionCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: colors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(fontSize: 14.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
