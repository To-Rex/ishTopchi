import 'package:flutter/material.dart';
import '../../config/theme/app_theme.dart';

/// Umumiy karta.
///
/// Soya (`elevation: 5`) olib tashlandi — chuqurlik yuza rangi va nozik
/// kontur bilan beriladi. Qorongʻi fonda soya baribir koʻrinmaydi, lekin
/// kartani "kir" koʻrsatadi.
class CustomCard extends StatelessWidget {
  final Widget child;

  const CustomCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
