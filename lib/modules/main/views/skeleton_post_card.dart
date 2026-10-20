import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/funcController.dart';

/// Eʼlon kartasining yuklanish holati.
///
/// Shakli [PostCard] bilan bir xil — roʻyxat yoki katak koʻrinishiga
/// qarab. Shunda haqiqiy kartalar kelganda ekran sakramaydi.
class SkeletonPostCard extends StatelessWidget {
  const SkeletonPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final FuncController funcController = Get.find<FuncController>();

    return Obx(
      () => _Shell(
        child:
            funcController.isGridView.value
                ? _buildGrid(context)
                : _buildList(context),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AspectRatio(aspectRatio: 16 / 10, child: _Block()),
        Padding(
          padding: const EdgeInsets.all(12),
          child: _buildLines(context, compact: true),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 128, child: _Block()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _buildLines(context, compact: false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLines(BuildContext context, {required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Bar(widthFactor: 0.75, height: 15),
        const SizedBox(height: 10),
        Row(
          children: const [
            _Bar(width: 78, height: 18, radius: 8),
            SizedBox(width: 8),
            Expanded(child: _Bar(widthFactor: 0.5, height: 11)),
          ],
        ),
        const SizedBox(height: 12),
        const _Bar(widthFactor: 1, height: 11),
        const SizedBox(height: 6),
        const _Bar(widthFactor: 0.8, height: 11),
        const SizedBox(height: 14),
        const _Bar(widthFactor: 0.45, height: 13),
        const SizedBox(height: 10),
        const _Bar(widthFactor: 0.6, height: 11),
        const SizedBox(height: 12),
        Row(
          children: const [
            _Bar(width: 22, height: 22, radius: 11),
            SizedBox(width: 8),
            Expanded(child: _Bar(widthFactor: 0.4, height: 11)),
          ],
        ),
      ],
    );
  }
}

/// Kartaning tashqi qobigʻi — haqiqiy karta bilan bir xil oʻlchamda.
class _Shell extends StatelessWidget {
  const _Shell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: colors.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: colors.onSurface.withValues(alpha: 0.07),
        highlightColor: colors.onSurface.withValues(alpha: 0.15),
        period: const Duration(milliseconds: 1400),
        child: child,
      ),
    );
  }
}

/// Toʻliq toʻldirilgan blok (surat oʻrni).
class _Block extends StatelessWidget {
  const _Block();

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}

/// Matn qatorining oʻrni.
///
/// Shimmer gradiyenti oq ustiga tushadi, shuning uchun rang shu yerda
/// ahamiyatsiz — muhimi shakl va oʻlcham.
class _Bar extends StatelessWidget {
  const _Bar({
    this.width,
    this.widthFactor,
    required this.height,
    this.radius = 6,
  });

  final double? width;
  final double? widthFactor;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    if (widthFactor == null) return bar;
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: bar,
    );
  }
}
