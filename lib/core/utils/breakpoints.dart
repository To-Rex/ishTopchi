import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Ekran kengligi sinflari.
///
/// Material 3 ning "window size class" chegaralari: telefon (< 600),
/// planshet yoki ochilgan qurilma (600–839), keng ekran (≥ 840).
enum ScreenSize { compact, medium, expanded }

/// Kenglikka bogʻliq oʻlchamlar.
///
/// Bu klass [Responsive] ning oʻrnini bosmaydi — u har bir oʻlchamni
/// koeffitsientga koʻpaytiradi, bu esa **chegaralarga** tayanadi. Farqi
/// muhim: koeffitsient bilan kattalashtirilgan interfeys planshetda
/// "yoyilib" ketadi, chegaralar esa ustun sonini oshiradi va kontentni
/// oʻqiladigan kenglikda ushlab turadi.
class AppBreakpoints {
  const AppBreakpoints._();

  static const double _medium = 600;
  static const double _expanded = 840;

  /// Matn qulay oʻqiladigan eng katta kenglik.
  ///
  /// Bundan kengroq ustunda koʻz qatorning boshiga qaytishda adashadi,
  /// shuning uchun keng ekranda kontent markazga yigʻiladi.
  static const double readableWidth = 680;

  /// Katakdagi bitta kartaning moʻljal kengligi.
  ///
  /// Ustun soni shu qiymatdan **hisoblanadi**, qoʻlda berilmaydi: shunda
  /// karta telefonda ham, planshetda ham bir xil oʻlchamda qoladi, faqat
  /// ustunlar soni oʻzgaradi.
  static const double tileExtent = 210;

  /// Telefonda katak doim 2 ustunli — avvalgidek. Kengroq ekranda
  /// ustun soni [tileExtent] dan hisoblanadi (`null`).
  static int? fixedGridColumns(BuildContext context) =>
      isCompact(context) ? 2 : null;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= _expanded) return ScreenSize.expanded;
    if (width >= _medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }

  static bool isCompact(BuildContext context) =>
      of(context) == ScreenSize.compact;

  /// Ekran chetidagi boʻshliq.
  static double gutter(BuildContext context) {
    switch (of(context)) {
      case ScreenSize.compact:
        return 16;
      case ScreenSize.medium:
        return 24;
      case ScreenSize.expanded:
        return 32;
    }
  }

  /// Kontent ustunining eng katta kengligi.
  ///
  /// Telefonda cheklov yoʻq (`double.infinity`) — u yerda ekran allaqachon
  /// tor, cheklov faqat ortiqcha hisob boʻlardi.
  static double maxContentWidth(BuildContext context) {
    return isCompact(context) ? double.infinity : readableWidth;
  }
}

/// Kontentni keng ekranda markazga yigʻadi.
///
/// Mavjud kenglik [maxWidth] dan oshmasa (barcha telefonlar) hech narsa
/// qilmaydi: cheklovlar bolaga oʻzgarishsiz oʻtadi.
///
/// Daraxt tuzilishi **har qanday kenglikda bir xil** — faqat chetdagi
/// boʻshliq oʻzgaradi. Ilgari telefonda bola toʻgʻridan-toʻgʻri
/// qaytarilar, kengroq ekranda esa `Align` ichiga oʻralardi. Ekran
/// 600dp chegarasini kesib oʻtganda (burilish, bukiladigan qurilma,
/// boʻlingan ekran) butun kontent qayta yaratilardi va lentadagi
/// `SmartRefresher` bitta kontrollerni ikki marta olib yiqilardi.
class AppContentWidth extends StatelessWidget {
  const AppContentWidth({super.key, required this.child, this.maxWidth});

  final Widget child;

  /// Standart qiymat — [AppBreakpoints.readableWidth].
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final limit = maxWidth ?? AppBreakpoints.readableWidth;

    return LayoutBuilder(
      builder: (context, constraints) {
        final extra =
            constraints.hasBoundedWidth
                ? math.max(0.0, constraints.maxWidth - limit)
                : 0.0;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: extra / 2),
          child: child,
        );
      },
    );
  }
}

/// Katak delegati: ustun soni kenglikdan, katak balandligi esa
/// **mazmundan** hisoblanadi.
///
/// Ilgari balandlik qatʼiy nisbatdan olinardi (`kenglik / 0.59`). Bu
/// karta ichidagi ikki xil narsani bitta raqamga bogʻlab qoʻyardi:
/// surat kenglikka qarab oʻsadi, matn esa oʻsmaydi. Natijada tor
/// ekranda yoki katta shriftda matnga joy yetmay, karta toshib ketardi.
///
/// Endi balandlik ikki qismdan yigʻiladi: suratning oʻz nisbatidagi
/// balandligi ([mediaAspectRatio]) va mazmun balandligi ([extraHeight]),
/// uni karta oʻzi oʻlchab beradi.
class AppTileGridDelegate extends SliverGridDelegate {
  const AppTileGridDelegate({
    required this.maxTileWidth,
    required this.mediaAspectRatio,
    this.mediaInset = 0,
    this.extraHeight = 0,
    this.fixedColumns,
    this.spacing = 4,
  });

  /// Katakning eng katta kengligi — ustun soni shundan chiqadi.
  final double maxTileWidth;

  /// Surat nisbati (kenglik / balandlik).
  final double mediaAspectRatio;

  /// Surat katakdan qancha tor (karta cheti va konturi).
  final double mediaInset;

  /// Suratdan tashqari hamma narsaning balandligi.
  final double extraHeight;

  /// Berilsa — ustun soni shu, kenglikdan hisoblanmaydi.
  final int? fixedColumns;

  final double spacing;

  int _columnsFor(double crossAxisExtent) {
    if (fixedColumns != null) return fixedColumns!;
    final count =
        ((crossAxisExtent + spacing) / (maxTileWidth + spacing)).ceil();
    return math.max(1, count);
  }

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final columns = _columnsFor(constraints.crossAxisExtent);
    final usable = constraints.crossAxisExtent - spacing * (columns - 1);
    final tileWidth = math.max(0.0, usable / columns);
    final mediaHeight =
        math.max(0.0, tileWidth - mediaInset) / mediaAspectRatio;
    final tileHeight = mediaHeight + extraHeight;

    return SliverGridRegularTileLayout(
      crossAxisCount: columns,
      mainAxisStride: tileHeight + spacing,
      crossAxisStride: tileWidth + spacing,
      childMainAxisExtent: tileHeight,
      childCrossAxisExtent: tileWidth,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(AppTileGridDelegate oldDelegate) {
    return oldDelegate.maxTileWidth != maxTileWidth ||
        oldDelegate.mediaAspectRatio != mediaAspectRatio ||
        oldDelegate.mediaInset != mediaInset ||
        oldDelegate.extraHeight != extraHeight ||
        oldDelegate.fixedColumns != fixedColumns ||
        oldDelegate.spacing != spacing;
  }
}
