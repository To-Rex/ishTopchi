import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

/// Tortib yangilash sarlavhasi.
///
/// API oʻzgarmadi. Standart rang `Colors.white` edi — yorugʻ mavzuda
/// oq fonda koʻrinmasdi; endi rang berilmasa mavzudan olinadi.
/// Koʻrsatkich ham qattiq koʻk oʻrniga mavzu rangida.
class CustomRefreshHeader extends StatelessWidget {
  final Color? color;

  const CustomRefreshHeader({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textColor = color ?? colors.onSurface.withValues(alpha: 0.6);

    return CustomHeader(
      height: 90,
      builder: (BuildContext context, RefreshStatus? mode) {
        final String? label = switch (mode) {
          RefreshStatus.idle => 'Ma’lumotlarni yangilash uchun tashlang'.tr,
          RefreshStatus.canRefresh =>
            'Ma’lumotlarni yangilash uchun tashlang'.tr,
          RefreshStatus.failed => 'Ehhh nimadir xato ketdi'.tr,
          RefreshStatus.refreshing => null,
          _ => 'Ma’lumotlar yangilandi'.tr,
        };

        return SizedBox(
          height: 60,
          child: Center(
            child:
                label == null
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    )
                    : Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 13.5,
                        color: textColor,
                      ),
                    ),
          ),
        );
      },
    );
  }
}

/// Tortib yuklash (pastki) qismi.
class CustomRefreshFooter extends StatelessWidget {
  final Color? color;

  /// Pastdan qoʻshimcha boʻshliq — belgi suzuvchi panel ostida
  /// qolmasligi uchun.
  final double bottomInset;

  const CustomRefreshFooter({super.key, this.color, this.bottomInset = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textColor = color ?? colors.onSurface.withValues(alpha: 0.6);

    return CustomFooter(
      height: 60 + bottomInset,
      builder: (BuildContext context, LoadStatus? mode) {
        final Widget body = switch (mode) {
          LoadStatus.idle => const SizedBox(),
          LoadStatus.canLoading => const SizedBox(),
          LoadStatus.loading => SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.primary,
            ),
          ),
          LoadStatus.failed => Text(
            'Ehhh nimadir xato ketdi'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13.5,
              color: textColor,
            ),
          ),
          _ => Text(
            'Ma’lumotlar yangilandi'.tr,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13.5,
              color: textColor,
            ),
          ),
        };

        return SizedBox(
          height: 60 + bottomInset,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Center(child: body),
          ),
        );
      },
    );
  }
}
