import 'package:flutter/material.dart';
import '../../config/theme/app_dimensions.dart';
import '../../config/theme/app_theme.dart';

/// Ilovaning asosiy tugmasi.
///
/// API ataylab oʻzgartirilmagan — tugma 20 dan ortiq ekranda ishlatiladi.
/// Oʻzgargani koʻrinish:
/// * radius 50 (tabletka) oʻrniga 16 — qolgan elementlar bilan bir shkala;
/// * `elevation: 10` va qora soya olib tashlandi;
/// * balandlik `Responsive` orqali emas, toʻgʻridan-toʻgʻri
///   [AppDimensions.buttonHeight] dan olinadi. `Responsive.scaleHeight`
///   `devicePixelRatio` ga boʻlgani uchun haqiqiy qurilmada har doim eng
///   kichik chegaraga tushardi va tugma 56 emas, ~45px boʻlib qolardi;
/// * `isLoading` endi aylanma koʻrsatkich chiqaradi — avval u faqat
///   tugmani xiralashtirib, bosishni oʻchirardi;
/// * bosilganda yumshoq kichrayadi.
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? iconSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.iconSize,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null && !widget.isLoading;

    final background = widget.backgroundColor ?? colors.primary;
    final foreground = widget.textColor ?? colors.onPrimary;
    final radius = BorderRadius.circular(AppTheme.radiusControl);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.text,
      child: AnimatedScale(
        scale: _pressed && enabled ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.5,
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
              splashColor: foreground.withValues(alpha: 0.08),
              highlightColor: foreground.withValues(alpha: 0.04),
              child: Container(
                height: AppDimensions.buttonHeight,
                // Avvalgi `minimumSize: Size(double.infinity, …)` bilan bir
                // xil: tugma ota-elementning butun kengligini egallaydi.
                width: double.infinity,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child:
                    widget.isLoading
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
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                size: widget.iconSize ?? 21,
                                color: foreground,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Flexible(
                              child: Text(
                                widget.text,
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
