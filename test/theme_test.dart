// Mavzu va responsivlik uchun tekshiruvlar.
//
// Bu yerda ekranlar emas, **dizayn tizimining oʻzi** tekshiriladi:
// qorongʻi mavzu haqiqatan neytral (koʻk emas) ekani, matn fondan
// yetarlicha ajralib turishi va kenglik chegaralarining toʻgʻri
// ishlashi. Shu uchun testlar tarmoq yoki GetX kontrollerlariga
// bogʻliq emas va tez ishlaydi.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishtopchi/config/theme/app_theme.dart';
import 'package:ishtopchi/core/utils/breakpoints.dart';

/// Rangning nisbiy yorqinligi (WCAG 2.1).
double _luminance(Color c) {
  double channel(double v) {
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4) as double;
  }

  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// Ikki rang orasidagi kontrast nisbati.
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Rang qanchalik "rangli" ekani: 0 — sof kulrang.
int _chroma(Color c) {
  final r = (c.r * 255).round();
  final g = (c.g * 255).round();
  final b = (c.b * 255).round();
  return math.max(r, math.max(g, b)) - math.min(r, math.min(g, b));
}

/// Ekranni berilgan oʻlchamda quradi.
///
/// `MediaQuery` ni qoʻlda almashtirish yetarli emas edi: u faqat
/// **maʼlumot** beradi, layout esa test yuzasining haqiqiy oʻlchamida
/// qolaveradi. Shuning uchun `tester.view` orqali yuzaning oʻzi
/// oʻzgartiriladi.
Future<void> _pumpAt(WidgetTester tester, Size size, Widget child) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery.fromView(
      view: tester.view,
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    ),
  );
}

void main() {
  group('Qorongʻi mavzu neytral', () {
    final dark = AppTheme.darkTheme;
    final colors = dark.colorScheme;

    test('fon qoraga yaqin va koʻk tusi yoʻq', () {
      // Foydalanuvchi aynan shuni soʻradi: koʻk emas, qora.
      expect(_chroma(colors.surface), lessThanOrEqualTo(6));
      expect(_luminance(colors.surface), lessThan(0.02));
    });

    test('kartalar fondan bir pogʻona yorugʻroq', () {
      expect(
        _luminance(colors.surfaceContainer),
        greaterThan(_luminance(colors.surface)),
      );
    });

    test('yuzalarda ham koʻk tus yoʻq', () {
      expect(_chroma(colors.surfaceContainer), lessThanOrEqualTo(6));
    });

    test('Flutter uchun ham qorongʻi hisoblanadi', () {
      expect(dark.brightness, Brightness.dark);
      expect(colors.brightness, Brightness.dark);
    });
  });

  group('Oʻqilishi', () {
    final dark = AppTheme.darkTheme.colorScheme;
    final light = AppTheme.lightTheme.colorScheme;

    test('qorongʻi: asosiy matn fonda AA', () {
      expect(_contrast(dark.onSurface, dark.surface), greaterThan(4.5));
      expect(
        _contrast(dark.onSurface, dark.surfaceContainer),
        greaterThan(4.5),
      );
    });

    test('qorongʻi: tugma yozuvi fonida AA', () {
      expect(_contrast(dark.onPrimary, dark.primary), greaterThan(4.5));
    });

    test('qorongʻi: urgʻu rangi fondan ajraladi', () {
      // Matn uchun AA (4.5) chegarasidan sal past — bitta koʻk bir vaqtda
      // ham oq yozuvni koʻtarib, ham qora fonda AA berolmaydi. Ikonkalar
      // va yirik urgʻu uchun talab 3:1, u bemalol bajariladi.
      expect(_contrast(dark.primary, dark.surface), greaterThan(3.0));
    });

    test('yorugʻ: asosiy matn va tugma yozuvi AA', () {
      expect(_contrast(light.onSurface, light.surface), greaterThan(4.5));
      expect(_contrast(light.onPrimary, light.primary), greaterThan(4.5));
    });
  });

  group('Kenglik chegaralari', () {
    testWidgets('telefon / planshet / keng ekran toʻgʻri aniqlanadi', (
      tester,
    ) async {
      final sizes = {
        const Size(360, 690): ScreenSize.compact,
        const Size(599, 900): ScreenSize.compact,
        const Size(600, 900): ScreenSize.medium,
        const Size(839, 1100): ScreenSize.medium,
        const Size(840, 1100): ScreenSize.expanded,
        const Size(1280, 800): ScreenSize.expanded,
      };

      for (final entry in sizes.entries) {
        late ScreenSize seen;
        await _pumpAt(
          tester,
          entry.key,
          Builder(
            builder: (context) {
              seen = AppBreakpoints.of(context);
              return const SizedBox();
            },
          ),
        );
        expect(seen, entry.value, reason: 'kenglik ${entry.key.width}');
      }
    });

    testWidgets('telefonda AppContentWidth hech narsani oʻzgartirmaydi', (
      tester,
    ) async {
      const key = Key('content');
      await _pumpAt(
        tester,
        const Size(360, 690),
        const AppContentWidth(
          child: SizedBox(key: key, width: double.infinity, height: 100),
        ),
      );

      expect(tester.getSize(find.byKey(key)).width, 360);
    });

    testWidgets('keng ekranda kontent oʻqiladigan kenglikda qoladi', (
      tester,
    ) async {
      const key = Key('content');
      await _pumpAt(
        tester,
        const Size(1280, 800),
        const AppContentWidth(
          child: SizedBox(key: key, width: double.infinity, height: 100),
        ),
      );

      expect(
        tester.getSize(find.byKey(key)).width,
        AppBreakpoints.readableWidth,
      );
    });

    testWidgets('katak ustunlari kenglikka qarab koʻpayadi', (tester) async {
      // Haqiqiy [GridView] quriladi va birinchi qatordagi kataklar
      // sanaladi — delegatning ichki hisobiga emas, natijaga qaraymiz.
      Future<int> columnsAt(double width) async {
        await _pumpAt(
          tester,
          Size(width, 900),
          Builder(
            builder: (context) {
              return GridView.builder(
                gridDelegate: AppTileGridDelegate(
                  maxTileWidth: AppBreakpoints.tileExtent,
                  mediaAspectRatio: 16 / 10,
                  extraHeight: 200,
                  fixedColumns: AppBreakpoints.fixedGridColumns(context),
                ),
                itemCount: 24,
                itemBuilder: (context, index) => SizedBox(key: ValueKey(index)),
              );
            },
          ),
        );

        final firstTop = tester.getTopLeft(find.byKey(const ValueKey(0))).dy;
        var count = 0;
        for (var i = 0; i < 24; i++) {
          final finder = find.byKey(ValueKey(i));
          if (finder.evaluate().isEmpty) break;
          if (tester.getTopLeft(finder).dy != firstTop) break;
          count++;
        }
        return count;
      }

      final phone = await columnsAt(360);
      final tablet = await columnsAt(768);
      final wide = await columnsAt(1280);

      expect(phone, 2, reason: 'telefonda avvalgidek 2 ustun');
      expect(tablet, greaterThan(phone), reason: 'planshetda koʻproq');
      expect(wide, greaterThan(tablet), reason: 'keng ekranda yana koʻproq');
    });
  });
}
