// Shakl elementlari.
//
// Roʻyxatdan oʻtish va profilni tahrirlash ekranlari bir xil maydonlardan
// iborat — avatar tanlash, viloyat/tuman tanlash va jins tanlash. Ular
// ikkala ekranda nusxalangan edi; endi shu yerda.

import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Profil surati tanlash.
///
/// Kamera tugmasi ilgari suratning pastki qismidagi yarim shaffof chiziq
/// ustida turardi va suratni toʻsib qoʻyardi. Endi u aylananing chekkasida
/// alohida tugma.
class AppAvatarPicker extends StatelessWidget {
  const AppAvatarPicker({
    super.key,
    required this.onPick,
    this.file,
    this.networkUrl,
    this.size = 112,
  });

  /// Tanlangan mahalliy fayl — u boʻlsa birinchi oʻrinda koʻrsatiladi.
  final File? file;

  /// Serverdagi surat manzili.
  final String? networkUrl;

  final VoidCallback onPick;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    Widget content;
    if (file != null) {
      content = Image.file(file!, fit: BoxFit.cover);
    } else if (networkUrl != null) {
      content = Image.network(
        networkUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, _, _) => _placeholder(colors),
      );
    } else {
      content = _placeholder(colors);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors.onSurface.withValues(alpha: 0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.onSurface.withValues(alpha: 0.10),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: content,
        ),
        Material(
          color: colors.primary,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPick,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                LucideIcons.camera,
                size: 16,
                color: colors.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(ColorScheme colors) => Icon(
    LucideIcons.user,
    size: size * 0.4,
    color: colors.onSurface.withValues(alpha: 0.45),
  );
}

/// Roʻyxatdan tanlanadigan maydon — yuklanish va boʻsh holat belgilari bilan.
class AppSelectField extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.items,
    required this.value,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.loading,
    required this.emptyMessage,
    required this.showEmptyMessage,
  });

  final List<Map<String, dynamic>> items;
  final String value;
  final String label;
  final IconData icon;
  final Function(String?) onChanged;
  final bool loading;
  final String emptyMessage;
  final bool showEmptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.centerRight,
          children: [
            DropdownButtonFormField2<String>(
              value:
                  value.isNotEmpty &&
                          items.any((item) => item['id'].toString() == value)
                      ? value
                      : null,
              isExpanded: true,
              validator:
                  (val) =>
                      val == null || val.isEmpty || val == '0'
                          ? '$label ${'tanlanishi shart'.tr}'
                          : null,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, size: 18),
                labelText: label,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 240,
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                offset: const Offset(0, -6),
              ),
              iconStyleData: IconStyleData(
                icon: Icon(
                  LucideIcons.chevronDown,
                  size: 18,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              style: theme.textTheme.bodyMedium,
              items:
                  items
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['name'] ?? 'Noma’lum'.tr),
                        ),
                      )
                      .toList(),
              onChanged: items.isEmpty ? null : onChanged,
              hint: Text(
                'Tanlang'.tr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.42),
                ),
              ),
            ),
            if (loading)
              Padding(
                padding: const EdgeInsets.only(right: 44),
                child: SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              ),
          ],
        ),
        if (showEmptyMessage)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              emptyMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colors.error,
              ),
            ),
          ),
      ],
    );
  }
}

/// Jins tanlash.
///
/// Qiymatlar avvalgidek: `'1'` — erkak, `'2'` — ayol.
class AppGenderSelector extends StatelessWidget {
  const AppGenderSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Jins'.tr, style: theme.textTheme.titleSmall),
        ),
        Row(
          children: [
            Expanded(
              child: _GenderOption(
                label: 'Erkak'.tr,
                icon: LucideIcons.mars,
                value: '1',
                selected: selected,
                onTap: () => onChanged('1'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderOption(
                label: 'Ayol'.tr,
                icon: LucideIcons.venus,
                value: '2',
                selected: selected,
                onTap: () => onChanged('2'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Jins tanlash uchun bitta variant.
///
/// `RadioListTile` oʻrniga: tanlangan variant kontur va fon rangi bilan
/// aniq koʻrinadi, oʻtish yumshoq animatsiya bilan boʻladi.
class _GenderOption extends StatelessWidget {
  const _GenderOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final String selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isSelected = selected == value;
    final radius = BorderRadius.circular(14);

    return Material(
      color:
          isSelected
              ? colors.primary.withValues(alpha: 0.10)
              : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color:
                  isSelected
                      ? colors.primary.withValues(alpha: 0.45)
                      : colors.onSurface.withValues(alpha: 0.18),
              width: isSelected ? 1.4 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 17,
                color:
                    isSelected
                        ? colors.primary
                        : colors.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 9),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? colors.primary : colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shakldagi oddiy matn maydoni.
class AppFormField extends StatelessWidget {
  const AppFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.requiredMessage,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;

  /// Boʻsh qoldirilganda koʻrsatiladigan xabar.
  final String? requiredMessage;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator:
          (value) =>
              value == null || value.trim().isEmpty
                  ? (requiredMessage ?? '$label ${'to‘ldirilishi shart'.tr}')
                  : null,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 18),
        labelText: label,
      ),
    );
  }
}
