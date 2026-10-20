// Pastki suzuvchi panel (Apple uslubi).
//
// Tekshiriladi:
// * har bir boʻlim bosilganda aynan oʻsha indeks tanlanadi (avvalgidek);
// * boʻlim almashganda telefon yengil tebranadi, joriy boʻlimni qayta
//   bosganda — yoʻq;
// * panel tor ekranda va katta shriftda sigʻadi;
// * kontent panel ostidan oʻtsa ham, lentaning oxirgi kartasi panel
//   ostida qolib ketmaydi.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;
import 'package:ishtopchi/common/widgets/glass_tab_bar.dart';
import 'package:ishtopchi/config/theme/app_theme.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import 'package:ishtopchi/core/models/post_model.dart';
import 'package:ishtopchi/modules/main/views/main_content.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _tabs = [
  GlassTab(LucideIcons.house, LucideIcons.house500, 'Asosiy'),
  GlassTab(LucideIcons.circlePlus, LucideIcons.circlePlus500, 'E’lon qo‘shish'),
  GlassTab(LucideIcons.messageCircle, LucideIcons.messageCircle500, 'Xabarlar'),
  GlassTab(LucideIcons.user, LucideIcons.user500, 'Profil'),
];

Data _post(int id) => Data(
  id: id,
  title: 'Eʼlon $id',
  content: 'Mijozlar bilan ishlash, hisobot yuritish.',
  salaryFrom: '6000000',
  salaryTo: '9000000',
  views: id,
  jobType: 'REMOTE',
  createdAt: '2026-10-01T10:00:00Z',
  user: User(firstName: 'Aziz', lastName: 'Karimov'),
  category: Category(title: 'IT'),
  district: District(name: 'Yunusobod tumani'),
);

/// Kapsulaning oʻzi — panel ichidagi yagona dumaloq kesim.
final _capsule = find.descendant(
  of: find.byType(GlassTabBar),
  matching: find.byType(ClipRRect),
);

/// Ilovadagi kabi: kontent panel ostidan oʻtadi (`extendBody`).
Future<void> _pumpShell(
  WidgetTester tester, {
  required Widget body,
  required int index,
  required ValueChanged<int> onSelect,
  double width = 392.7,
  double scale = 1,
  Brightness brightness = Brightness.dark,
  double bottomSafeArea = 34,
  bool reduceEffects = false,
}) async {
  tester.view.physicalSize = Size(width, 852);
  tester.view.devicePixelRatio = 1;
  tester.view.padding = FakeViewPadding(bottom: bottomSafeArea);
  tester.view.viewPadding = FakeViewPadding(bottom: bottomSafeArea);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          brightness == Brightness.dark
              ? AppTheme.darkTheme
              : AppTheme.lightTheme,
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
      home: Scaffold(
        extendBody: true,
        body: body,
        bottomNavigationBar: GlassTabBar(
          tabs: _tabs,
          currentIndex: index,
          onSelect: onSelect,
          reduceEffects: reduceEffects,
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('ishtopchi_tabbar_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => dir.path,
        );
    await GetStorage.init();
    Get.put(FuncController());
    Get.put(ApiController());
  });

  tearDownAll(Get.reset);

  testWidgets('har bir boʻlim oʻz indeksini tanlaydi', (tester) async {
    var current = 0;
    final selected = <int>[];

    for (var i = 0; i < _tabs.length; i++) {
      await _pumpShell(
        tester,
        body: const SizedBox.expand(),
        index: current,
        onSelect: (value) {
          selected.add(value);
          current = value;
        },
      );
      await tester.tap(find.text(_tabs[i].label));
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(selected, [0, 1, 2, 3]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('almashganda tebranadi, joriysini bosganda — yoʻq', (
    tester,
  ) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await _pumpShell(
      tester,
      body: const SizedBox.expand(),
      index: 0,
      onSelect: (_) {},
    );

    await tester.tap(find.text('Asosiy'));
    await tester.pump();
    expect(haptics, isEmpty, reason: 'joriy boʻlim');

    await tester.tap(find.text('Xabarlar'));
    await tester.pump();
    expect(haptics, ['HapticFeedbackType.selectionClick']);
  });

  testWidgets('tanlangan boʻlim ekran oʻquvchiga "tanlangan" deb aytiladi', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _pumpShell(
      tester,
      body: const SizedBox.expand(),
      index: 2,
      onSelect: (_) {},
    );

    expect(
      tester.getSemantics(find.bySemanticsLabel('Xabarlar')),
      isSemantics(
        label: 'Xabarlar',
        isButton: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  for (final brightness in Brightness.values) {
    testWidgets('panel sigʻadi — ${brightness.name}', (tester) async {
      for (final width in [320.0, 360.0, 392.7, 430.0, 768.0]) {
        for (final scale in [1.0, 1.3]) {
          for (var index = 0; index < _tabs.length; index++) {
            await _pumpShell(
              tester,
              body: const SizedBox.expand(),
              index: index,
              onSelect: (_) {},
              width: width,
              scale: scale,
              brightness: brightness,
              // Ikkala rejim ham navbatma-navbat sinaladi.
              reduceEffects: index.isOdd,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: '${width}dp, ×$scale, boʻlim $index',
            );
          }
        }
      }
    });
  }

  testWidgets('xiralik zonasidagi bosish ostidagi kontentga oʻtadi', (
    tester,
  ) async {
    var tapped = 0;
    await _pumpShell(
      tester,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => tapped++,
            ),
          ),
        ],
      ),
      index: 0,
      onSelect: (_) {},
    );

    // Kapsula yonidagi chet va kapsula ostidagi boʻshliq — ikkalasi ham
    // xiralik zonasida, lekin kapsula ustida emas.
    final capsule = tester.getRect(_capsule);
    final bar = tester.getRect(find.byType(GlassTabBar));
    await tester.tapAt(Offset(bar.left + 6, capsule.center.dy));
    await tester.tapAt(
      Offset(bar.center.dx, (capsule.bottom + bar.bottom) / 2),
    );
    expect(tapped, 2);
  });

  testWidgets('xiralik kapsulaning yuqori chizigʻidan boshlanadi', (
    tester,
  ) async {
    for (final reduce in [false, true]) {
      await _pumpShell(
        tester,
        body: const SizedBox.expand(),
        index: 0,
        onSelect: (_) {},
        reduceEffects: reduce,
      );
      // Panel (demak xiralik zonasi ham) kapsula bilan bir chiziqdan
      // boshlanadi — undan yuqoridagi kontentga tegilmaydi.
      expect(
        tester.getTopLeft(find.byType(GlassTabBar)).dy,
        tester.getTopLeft(_capsule).dy,
        reason: reduce ? 'yengil rejim' : 'oddiy rejim',
      );
    }
  });

  testWidgets('oddiy rejim: xiralash qatlamlari bitta guruhda', (tester) async {
    await _pumpShell(
      tester,
      body: const SizedBox.expand(),
      index: 0,
      onSelect: (_) {},
    );

    // 5 ta oʻtish + 1 ta asos + kapsulaning oʻzi. Avval 12 ta edi va
    // orqa fon ikki marta oʻqilardi.
    expect(find.byType(BackdropFilter), findsNWidgets(7));
    expect(find.byType(BackdropGroup), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('yengil rejim: birorta ham xiralash yoʻq', (tester) async {
    await _pumpShell(
      tester,
      body: const SizedBox.expand(),
      index: 1,
      onSelect: (_) {},
      reduceEffects: true,
    );

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(BackdropGroup), findsNothing);
    // Panel baribir toʻliq ishlaydi.
    expect(find.text('Xabarlar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lenta oxiri panel ostida qolmaydi', (tester) async {
    final f =
        Get.find<FuncController>()
          ..isGridView.value = false
          ..isLoading.value = false
          ..hasMore.value = true;
    f.posts.assignAll([for (var i = 0; i < 8; i++) _post(i)]);
    f.totalPosts.value = 8;

    await _pumpShell(
      tester,
      body: const MainContent(),
      index: 0,
      onSelect: (_) {},
    );

    // Lentaning oʻzini (qidiruv maydonining ichki gorizontal
    // aylantirgichini emas) oxirigacha suramiz.
    final position = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .map((state) => state.position)
        .firstWhere((p) => p.axis == Axis.vertical && p.maxScrollExtent > 0);
    position.jumpTo(position.maxScrollExtent);
    await tester.pump(const Duration(seconds: 1));

    final lastCardBottom = tester.getBottomLeft(find.text('Eʼlon 7')).dy;
    final barTop = tester.getTopLeft(find.byType(GlassTabBar)).dy;
    final lastCard =
        tester
            .getRect(
              find
                  .ancestor(
                    of: find.text('Eʼlon 7'),
                    matching: find.byType(Material),
                  )
                  .first,
            )
            .bottom;

    expect(lastCardBottom, lessThan(barTop));
    expect(lastCard, lessThanOrEqualTo(barTop), reason: 'karta toʻliq');
    expect(tester.takeException(), isNull);
  });
}
