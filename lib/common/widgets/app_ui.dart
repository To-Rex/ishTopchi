// Ilovaning umumiy dizayn qismlari.
//
// Bu yerdagi widgetlar ekranlar boʻylab takrorlanadigan naqshlarni bitta
// joyda saqlaydi: ekran karkasi, yumshoq chiqish animatsiyasi, sarlavha
// bloki va tugma. Ular mavzuni oʻzi oʻrnatmaydi — ranglarni atrofdagi
// [Theme] dan oladi, shuning uchun ilova mavzusi bilan hech qachon
// ajralib qolmaydi.

import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';

/// Ekran karkasi: fon, ixtiyoriy yuqori panel va xavfsiz maydon.
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.child,
    this.title,
    this.showBack = true,
    this.actions,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;

  /// Yuqori paneldagi sarlavha. `null` boʻlsa ham panel koʻrsatiladi —
  /// [showBack] `true` boʻlsa orqaga tugmasi uchun.
  final String? title;

  final bool showBack;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasBar = showBack || title != null || actions != null;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar:
          hasBar
              ? AppBar(
                // Standart orqaga tugmasi — navigatsiya xulqi oʻzgarmaydi.
                automaticallyImplyLeading: showBack,
                title: title == null ? null : Text(title!),
                actions: actions,
              )
              : null,
      // Keng ekranda kontent markazda, oʻqiladigan kenglikda qoladi.
      // Telefonda [AppContentWidth] hech narsa qilmaydi.
      body: SafeArea(
        child: AppContentWidth(child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

/// Elementni yumshoq koʻtarilish va soʻnish bilan chiqaradi.
///
/// `AnimationController` kerak emas: [TweenAnimationBuilder] birinchi
/// qurilishda bir marta ishlaydi. Kechikish `Interval` orqali beriladi,
/// shuning uchun elementlar navbat bilan chiqadi va ekran bir butun
/// harakat sifatida ochiladi.
class AppReveal extends StatelessWidget {
  const AppReveal({super.key, required this.child, this.delay});

  final Widget child;

  /// Element qancha kechikib chiqishi.
  final Duration? delay;

  /// Bitta element animatsiyasining davomiyligi.
  static const Duration _base = Duration(milliseconds: 460);

  /// Element shuncha piksel pastdan koʻtariladi.
  static const double _rise = 12;

  /// Roʻyxatdagi `index` uchun tayyor kechikish.
  ///
  /// Kechikish chegaralangan: uzun roʻyxatda oxirgi element bir necha
  /// soniya kutib qolmasligi kerak.
  static Duration step(int index) {
    final ms = (index * 45).clamp(0, 360);
    return Duration(milliseconds: ms);
  }

  @override
  Widget build(BuildContext context) {
    // Tizimda "harakatni kamaytirish" yoqilgan boʻlsa — darhol oxirgi holat.
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    // RepaintBoundary: animatsiya davomida element qaytadan chizilmaydi —
    // keshlangan qatlam faqat siljiydi va soʻnadi. Roʻyxat aylanayotganda
    // yangi kartalar chiqishida bu har kadrda butun kartani qayta
    // chizishning oldini oladi.
    final content = RepaintBoundary(child: child);
    if (reduceMotion) return content;

    final wait = delay ?? Duration.zero;
    final total = _base + wait;
    final start = wait.inMilliseconds / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: total,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, _rise * (1 - t)),
            child: child,
          ),
        );
      },
      child: content,
    );
  }
}

/// Ekran sarlavhasi va uning tagidagi izoh.
class AppHeading extends StatelessWidget {
  const AppHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.titleSize,
  });

  final String title;
  final String? subtitle;

  /// Standart oʻlcham mavzudan (`headlineLarge`) olinadi.
  final double? titleSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(fontSize: titleSize),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(
            subtitle!,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              color: colors.onSurface.withValues(alpha: 0.58),
            ),
          ),
        ],
      ],
    );
  }
}

/// Tizim tugmasi.
///
/// Ikki koʻrinishi bor: konturli (ikkilamchi) va toʻldirilgan (asosiy).
/// Soya yoʻq — chuqurlik faqat rang kontrasti bilan beriladi.
///
/// Ikonka `Widget` sifatida beriladi, `IconData` emas: shunda Material
/// ikonkasi ham, FontAwesome brend belgisi ham bir xil ishlaydi.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leading,
    this.loading = false,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool loading;
  final bool filled;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;
    final radius = BorderRadius.circular(AppTheme.radiusControl);

    final foreground = widget.filled ? colors.onPrimary : colors.onSurface;
    final background = widget.filled ? colors.primary : Colors.transparent;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: AnimatedScale(
        scale: _pressed && enabled ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.45,
          duration: const Duration(milliseconds: 220),
          child: Material(
            color: background,
            borderRadius: radius,
            child: InkWell(
              onTap: enabled ? widget.onPressed : null,
              onTapDown: enabled ? (_) => _setPressed(true) : null,
              onTapUp: enabled ? (_) => _setPressed(false) : null,
              onTapCancel: enabled ? () => _setPressed(false) : null,
              borderRadius: radius,
              splashColor: foreground.withValues(alpha: 0.07),
              highlightColor: foreground.withValues(alpha: 0.04),
              child: Container(
                height: AppDimensions.buttonHeight,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border:
                      widget.filled
                          ? null
                          : Border.all(
                            color: colors.onSurface.withValues(alpha: 0.22),
                            width: 1.2,
                          ),
                ),
                alignment: Alignment.center,
                child:
                    widget.loading
                        ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: foreground,
                          ),
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.leading != null) ...[
                              IconTheme.merge(
                                data: IconThemeData(
                                  color: foreground,
                                  size: 20,
                                ),
                                child: widget.leading!,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Text(
                                widget.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: foreground,
                                ),
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Roʻyxat qatori: belgi, sarlavha, izoh va ixtiyoriy oʻng tomon.
///
/// Sozlamalar, profil, yordam va ilova haqida ekranlarida bir xil naqsh
/// takrorlanadi, shuning uchun bitta joyda saqlanadi.
class AppTile extends StatelessWidget {
  const AppTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Oʻng tomondagi element. `null` va [onTap] berilgan boʻlsa — strelka.
  final Widget? trailing;

  final VoidCallback? onTap;
  final Color? iconColor;

  /// Xavfli harakat (masalan oʻchirish) — belgi va yozuv qizil boʻladi.
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppTheme.radiusCard);
    final accent = danger ? colors.error : (iconColor ?? colors.primary);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: theme.cardTheme.color ?? colors.surfaceContainer,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 18, color: accent),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: danger ? colors.error : colors.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12.5,
                            color: colors.onSurface.withValues(alpha: 0.58),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 10),
                  trailing!,
                ] else if (onTap != null) ...[
                  const SizedBox(width: 10),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: colors.onSurface.withValues(alpha: 0.35),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Boʻlim sarlavhasi — katta harflar, keng interval.
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 10),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 11,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Boʻsh holat: dumaloq belgi, sarlavha, izoh va ixtiyoriy harakat.
///
/// Bir xil naqsh saralanganlar, eʼlonlar va bildirishnomalar ekranlarida
/// takrorlanadi, shuning uchun bitta joyda saqlanadi.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? actionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppReveal(
              child: Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.onSurface.withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 44,
                  color: colors.onSurface.withValues(alpha: 0.45),
                ),
              ),
            ),
            const SizedBox(height: 26),
            AppReveal(
              delay: const Duration(milliseconds: 90),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 10),
              AppReveal(
                delay: const Duration(milliseconds: 150),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 30),
              AppReveal(
                delay: const Duration(milliseconds: 210),
                child: AppButton(
                  label: actionLabel!,
                  leading: actionIcon,
                  filled: true,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Matn maydonining chap tomonidagi doimiy prefiks.
///
/// Nozik vertikal chiziq prefiks bilan kiritish maydonini ajratadi —
/// shunda ular bir-biriga tegib turgandek emas, bogʻlangandek koʻrinadi.
class AppFieldPrefix extends StatelessWidget {
  const AppFieldPrefix({super.key, required this.text, this.textStyle});

  final String text;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 18),
        Text(
          text,
          style: (textStyle ?? const TextStyle()).copyWith(
            color: colors.onSurface.withValues(alpha: 0.60),
          ),
        ),
        const SizedBox(width: 14),
        Container(width: 1.2, height: 24, color: colors.outline),
        const SizedBox(width: 14),
      ],
    );
  }
}

/// Xaritadagi belgi.
///
/// `Icons.location_pin` qizil rangda ilovaning boshqa hech qayeriga
/// mos tushmaydi. Buning oʻrniga oq halqa ichidagi toʻq nuqta: har
/// qanday xarita ustida aniq koʻrinadi va brend rangida qoladi.
class AppMapPin extends StatelessWidget {
  const AppMapPin({super.key, this.accent = true});

  /// `false` — joriy joylashuv (ikkilamchi), `true` — tanlangan nuqta.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final fill = accent ? colors.primary : colors.onSurface;
    final size = accent ? 18.0 : 14.0;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
        ),
      ),
    );
  }
}
