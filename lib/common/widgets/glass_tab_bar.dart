import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../core/utils/device_capabilities.dart';

/// Pastki paneldagi bitta boʻlim.
class GlassTab {
  const GlassTab(this.icon, this.activeIcon, this.label);

  final IconData icon;

  /// Tanlangan holat — xuddi shu belgi, chizigʻi qalinroq. Apple ham
  /// tanlangan boʻlimni rang bilan birga belgi "ogʻirligi" bilan ajratadi.
  final IconData activeIcon;

  /// Tarjima kaliti.
  final String label;
}

/// Pastki navigatsiya — Apple (iOS 26) uslubidagi suzuvchi shisha panel.
///
/// * Panel ekran chetiga yopishmaydi, kapsula shaklida suzib turadi.
/// * Orqasidagi kontent xiralashtirilib koʻrinadi (frosted glass).
/// * Tanlangan boʻlim ostida kapsula sirpanadi: harakat yoʻnalishidagi
///   cheti oldinroq, orqadagisi kechroq yetib boradi, shuning uchun
///   kapsula yoʻlda biroz choʻziladi va joyiga "oqib" tushadi.
/// * Bosilganda belgi yengil kichrayadi va telefon tebranadi.
class GlassTabBar extends StatelessWidget {
  const GlassTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onSelect,
    this.reduceEffects,
  });

  final List<GlassTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// Xiralashsiz, yengil rejim. Berilmasa — qurilmaga qarab
  /// ([DeviceCapabilities.reduceEffects]) aniqlanadi.
  final bool? reduceEffects;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final lite = reduceEffects ?? DeviceCapabilities.reduceEffects;
    // Uy tugmasi chizigʻi / tizim paneli bilan toʻqnashmaslik uchun.
    final bottom = math.max(media.viewPadding.bottom, 12.0);

    final bar = Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          // Planshetda panel ekran boʻylab choʻzilmaydi.
          constraints: const BoxConstraints(maxWidth: 440),
          // Panel ichidagi yozuvlar juda kattalashib ketmasin — Apple
          // ham panel yozuvlarini cheklangan oʻlchamda saqlaydi.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.2,
            child: _GlassBar(
              tabs: tabs,
              currentIndex: currentIndex,
              onSelect: onSelect,
              lite: lite,
            ),
          ),
        ),
      ),
    );

    final content = Stack(
      children: [
        // Apple'ning "scroll edge" effekti: kapsulaning yuqori
        // chizigʻidan boshlab pastga tomon kontent erib boradi.
        // Bosishlarni oʻtkazib yuboradi — kapsula yonidagi va ostidagi
        // roʻyxat avvalgidek bosiladi va aylantiriladi.
        Positioned.fill(
          child: IgnorePointer(
            child: _ScrollEdge(rampHeight: _GlassBarState._height, lite: lite),
          ),
        ),
        bar,
      ],
    );

    // Panelning oʻz qayta chizilishi (kapsula animatsiyasi) sahifaga
    // tarqalmaydi va aksincha.
    return RepaintBoundary(
      // Barcha xiralash qatlamlari — kapsulaniki ham — bitta guruhda:
      // orqa fon har kadrda bir marta oʻqiladi.
      child: lite ? content : BackdropGroup(child: content),
    );
  }
}

/// Kapsula yonida va ostida kontentning pastga tomon "erib" ketishi.
///
/// Zona kapsulaning yuqori chizigʻidan boshlanadi (undan yuqoridagi
/// kontentga tegilmaydi) va ikki qismdan iborat:
/// * **Oʻtish** — kapsula balandligi boʻylab bir nechta qatlam, har biri
///   oldingisidan sal kuchliroq. Ular faqat kapsula yonidagi ingichka
///   chetlarda koʻrinadi.
/// * **Asos** — kapsuladan pastga: bitta toʻliq kuchdagi qatlam.
///
/// Gradiyent ham, niqob ham ishlatilmaydi. Niqob (`ShaderMask`) ichidagi
/// `BackdropFilter` orqadagi kontentni koʻrmaydi, shuning uchun bu usul
/// ishonchsiz.
///
/// [lite] rejimda xiralash yoʻq: kontent shunchaki fon rangiga asta
/// soʻnadi. Bu rangni ustma-ust qoʻyish xolos — deyarli bepul.
class _ScrollEdge extends StatelessWidget {
  const _ScrollEdge({required this.rampHeight, required this.lite});

  /// Oʻtish qismining balandligi (zona tepasidan).
  final double rampHeight;

  final bool lite;

  /// Oʻtishdagi qatlamlar soni. Avval 10 ta edi; endi oʻtish faqat
  /// kapsula yonidagi ingichka chetlarda koʻrinadi, u yerda 5 ta yetarli.
  static const int _rampSteps = 5;

  /// Toʻliq kuchdagi xiralik.
  static const double _sigma = 10;

  /// Toʻliq kuchdagi parda — Apple ham kontentni panel ostida soʻndiradi.
  static const double _veil = 0.35;

  /// Yengil rejimda xiralik yoʻq, shuning uchun parda qalinroq.
  static const double _liteVeil = 0.88;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = theme.scaffoldBackgroundColor;

    // Android'da `BackdropFilter` iOS'ga qaraganda ancha qimmat: har bir
    // qatlam orqa fonni qaytadan xiralashtiradi. Shuning uchun Android'da
    // butun zona uchun bitta qatlam ishlatiladi. iOS'da avvalgidek
    // bosqichma-bosqich soʻnuvchi qatlamlar qoladi.
    final singleLayer = !lite && theme.platform == TargetPlatform.android;

    Widget layer(double strength) {
      if (lite) {
        return ColoredBox(
          color: background.withValues(alpha: _liteVeil * strength),
        );
      }
      return ClipRect(
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(
            sigmaX: _sigma * strength,
            sigmaY: _sigma * strength,
          ),
          child: ColoredBox(
            color: background.withValues(alpha: _veil * strength),
          ),
        ),
      );
    }

    if (singleLayer) {
      // Bitta xiralash qatlami + ustidan parda. Parda yuqori chetida
      // shaffof, pastda toʻliq — iOS'dagi bosqichma-bosqich soʻnishning
      // arzon koʻrinishi (gradient chizish deyarli bepul).
      return LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          final ramp = math.min(rampHeight, height);

          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                BackdropFilter.grouped(
                  filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
                  child: const SizedBox.expand(),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: ramp,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              background.withValues(alpha: 0),
                              background.withValues(alpha: _veil),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ColoredBox(
                        color: background.withValues(alpha: _veil),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final ramp = math.min(rampHeight, height);
        // Chegaralar butun piksellarga yaxlitlanadi va qoʻshni qatlamlar
        // bir xil chegarani boʻlishadi — oralarida chiziq ham, ustma-ust
        // tushish ham boʻlmaydi.
        double edge(int i) => (ramp * i / _rampSteps).roundToDouble();

        return Stack(
          children: [
            for (var i = 0; i < _rampSteps; i++)
              Positioned(
                left: 0,
                right: 0,
                top: edge(i),
                height: edge(i + 1) - edge(i),
                child: layer((i + 1) / (_rampSteps + 1)),
              ),
            Positioned(
              left: 0,
              right: 0,
              top: edge(_rampSteps),
              bottom: 0,
              child: layer(1),
            ),
          ],
        );
      },
    );
  }
}

class _GlassBar extends StatefulWidget {
  const _GlassBar({
    required this.tabs,
    required this.currentIndex,
    required this.onSelect,
    required this.lite,
  });

  final List<GlassTab> tabs;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  /// Xiralashsiz rejim — kapsula deyarli toʻliq rangli.
  final bool lite;

  @override
  State<_GlassBar> createState() => _GlassBarState();
}

class _GlassBarState extends State<_GlassBar> {
  static const double _height = 62;
  static const double _inset = 5;

  /// Biroz "sakrab" toʻxtaydigan egri chiziq — iOS'dagi prujina
  /// harakatiga yaqin, lekin keskin emas.
  static const Curve _spring = Cubic(0.34, 1.28, 0.64, 1);

  late int _previous = widget.currentIndex;

  @override
  void didUpdateWidget(covariant _GlassBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previous = oldWidget.currentIndex;
    }
  }

  void _select(int index) {
    if (index != widget.currentIndex) HapticFeedback.selectionClick();
    widget.onSelect(index);
  }

  /// Kapsula orqasidagi xiralik — chetdagi qatlamlar bilan bitta guruhda.
  static Widget _maybeBlur({required bool enabled, required Widget child}) {
    if (!enabled) return child;
    return BackdropFilter.grouped(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    // Shaffoflik ataylab past emas: orqadagi kontent xiralashib koʻrinadi,
    // lekin belgilar har qanday fonda oʻqiladi.
    // Yengil rejimda orqasi xiralashmaydi, shuning uchun kapsula deyarli
    // toʻliq rangli — ostidagi kontent belgilarga xalaqit bermaydi.
    final glassAlpha = widget.lite ? 0.97 : (isDark ? 0.70 : 0.72);
    final glass =
        isDark
            ? const Color(0xFF1C1C1F).withValues(alpha: glassAlpha)
            : Colors.white.withValues(alpha: glassAlpha);
    final hairline =
        isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.06);
    final lens =
        isDark
            ? Colors.white.withValues(alpha: 0.10)
            : colors.primary.withValues(alpha: 0.10);
    // Qorongʻi shishada brend koʻki biroz yoritiladi — aks holda
    // kichik belgi va yozuv fonga singib ketadi.
    final activeColor =
        isDark
            ? Color.lerp(colors.primary, Colors.white, 0.28)!
            : colors.primary;
    final idleColor = colors.onSurface.withValues(alpha: isDark ? 0.62 : 0.55);

    final radius = BorderRadius.circular(_height / 2);
    final count = widget.tabs.length;
    final movingRight = widget.currentIndex >= _previous;

    // Harakat yoʻnalishidagi chet tezroq, orqadagisi sekinroq.
    Duration edge(bool leading) =>
        reduceMotion
            ? Duration.zero
            : Duration(milliseconds: leading ? 300 : 440);

    return DecoratedBox(
      // Soya faqat panel "suzib" turganini bildiradi — juda yumshoq.
      decoration: BoxDecoration(
        borderRadius: radius,
        // Manfiy `spreadRadius` — soya yon tomonlardan chiqmaydi, faqat
        // pastda yengil "koʻtarilish" hissini beradi.
        // Yengil rejimda soya ham chizilmaydi — kontur yetarli.
        boxShadow:
            widget.lite
                ? null
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.07),
                    blurRadius: 22,
                    spreadRadius: -6,
                    offset: const Offset(0, 8),
                  ),
                ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: _maybeBlur(
          // Android'da ostidagi yagona qatlam orqa fonni allaqachon
          // xiralashtirgan — ikkinchi marta xiralashtirish ortiqcha.
          enabled: !widget.lite && theme.platform != TargetPlatform.android,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: glass,
              borderRadius: radius,
              border: Border.all(color: hairline, width: 0.8),
            ),
            child: SizedBox(
              height: _height,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / count;
                  final left = widget.currentIndex * itemWidth + _inset;
                  final right = (widget.currentIndex + 1) * itemWidth - _inset;

                  return Stack(
                    children: [
                      // Tanlangan boʻlim ostidagi kapsula.
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: left),
                        duration: edge(!movingRight),
                        curve: _spring,
                        builder:
                            (context, l, _) => TweenAnimationBuilder<double>(
                              tween: Tween<double>(end: right),
                              duration: edge(movingRight),
                              curve: _spring,
                              builder:
                                  (context, r, _) => Positioned(
                                    left: l,
                                    width: math.max(0.0, r - l),
                                    top: _inset,
                                    bottom: _inset,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: lens,
                                        borderRadius: BorderRadius.circular(
                                          (_height - _inset * 2) / 2,
                                        ),
                                      ),
                                    ),
                                  ),
                            ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < count; i++)
                            Expanded(
                              child: _TabButton(
                                spec: widget.tabs[i],
                                selected: i == widget.currentIndex,
                                activeColor: activeColor,
                                idleColor: idleColor,
                                onTap: () => _select(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paneldagi bitta tugma: belgi va yozuv.
class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.spec,
    required this.selected,
    required this.activeColor,
    required this.idleColor,
    required this.onTap,
  });

  final GlassTab spec;
  final bool selected;
  final Color activeColor;
  final Color idleColor;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.spec.label.tr;

    // Ichki belgi va yozuv alohida oʻqilmaydi — bitta "tugma" boʻlib
    // eshitiladi. Bosish amali shu yerda beriladi, chunki
    // `excludeSemantics` ichki `GestureDetector` amalini ham yashiradi.
    return Semantics(
      button: true,
      selected: widget.selected,
      label: label,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _pressed ? 0.88 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end: widget.selected ? widget.activeColor : widget.idleColor,
            ),
            duration: const Duration(milliseconds: 220),
            builder: (context, color, _) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tanlanganda belgi qalinroq variantiga yumshoq oʻtadi.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      widget.selected
                          ? widget.spec.activeIcon
                          : widget.spec.icon,
                      key: ValueKey(widget.selected),
                      size: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Tor ekranda yozuv qisqartirilmaydi, biroz kichrayadi —
                  // Apple panelidagi kabi.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.2,
                          letterSpacing: 0.1,
                          fontWeight:
                              widget.selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
