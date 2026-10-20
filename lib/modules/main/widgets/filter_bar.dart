import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Qidiruv va filtr qatori.
///
/// Eslatma: bu widget hozircha hech bir ekranda ishlatilmayapti —
/// lentadagi qidiruv `main_content.dart` ichida qurilgan. Uslubi baribir
/// mavzuga bogʻlandi, shunda ishlatilganda darhol toʻgʻri koʻrinadi.
class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              // Bezak mavzudagi `inputDecorationTheme` dan keladi.
              decoration: InputDecoration(
                hintText: 'Qidirish...'.tr,
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 18,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(LucideIcons.slidersHorizontal, color: colors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
