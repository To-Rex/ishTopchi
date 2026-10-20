import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../controllers/funcController.dart';

/// Pastdan ochiladigan varaqlar.
class BottomSheets {
  //getcontroller
  final FuncController funcController = Get.put(FuncController());

  /// Tillar roʻyxati: kod va koʻrsatiladigan nom.
  ///
  /// Ilgari toʻrt til toʻrt marta nusxalangan `ListTile` sifatida
  /// yozilgan edi; endi roʻyxatdan quriladi.
  static const List<({String code, String label})> _languages = [
    (code: 'uz', label: 'O‘zbekcha'),
    (code: 'oz', label: 'Ўзбекча'),
    (code: 'ru', label: 'Русский'),
    (code: 'en', label: 'English'),
  ];

  void showLanguageBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    Get.bottomSheet(
      // Shakl va fon mavzudagi `bottomSheetTheme` dan keladi.
      SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? colors.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Afzal ko‘rgan tilingizni tanlang'.tr,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 18),
              for (final language in _languages)
                _LanguageTile(
                  label: language.label,
                  selected: Get.locale?.languageCode == language.code,
                  onTap: () {
                    funcController.saveLanguage(language.code);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bitta til qatori.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(14);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color:
            selected
                ? colors.primary.withValues(alpha: 0.10)
                : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color:
                    selected
                        ? colors.primary.withValues(alpha: 0.35)
                        : colors.onSurface.withValues(alpha: 0.10),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? colors.primary : colors.onSurface,
                    ),
                  ),
                ),
                // Belgi almashuvi yumshoq boʻlishi uchun.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: Icon(
                    selected ? LucideIcons.circleCheck : LucideIcons.circle,
                    key: ValueKey(selected),
                    size: 19,
                    color:
                        selected
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
