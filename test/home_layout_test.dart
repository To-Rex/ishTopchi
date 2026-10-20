// Asosiy sahifa: tepa qismi siqilmasligi va boshqaruvlari ishlashi.
//
// Foydalanuvchi shikoyati: joylashuv, eʼlonlar soni, filtr va koʻrinish
// tugmasi bitta qatorga tiqilib, elementlar siqilib qolgan edi. Endi ular
// ikki qatorga ajratilgan; bu test ularning istalgan ekran kengligi va
// shrift oʻlchamida sigʻishini, filtr varagʻi va almashtirgichlar esa
// avvalgidek ishlashini tekshiradi.

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;
import 'package:ishtopchi/config/theme/app_theme.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import 'package:ishtopchi/core/models/post_model.dart';
import 'package:ishtopchi/core/models/user_me.dart' as me;
import 'package:ishtopchi/modules/main/views/main_content.dart';

const _imageUrl = 'https://example.test/vacancy.jpg';

Data _post(int id) => Data(
  id: id,
  title: 'Katta savdo markaziga tajribali sotuvchi-konsultant kerak',
  content:
      'Mijozlar bilan ishlash, tovarlarni joylashtirish, kassa bilan '
      'ishlash va hisobot yuritish. Tajriba talab qilinadi.',
  salaryFrom: '12000000',
  salaryTo: '18000000',
  views: 12345,
  jobType: 'PROJECT_BASED',
  createdAt: '2026-10-01T10:00:00Z',
  pictureUrl: id.isEven ? _imageUrl : null,
  user: User(firstName: 'Abdulazizxon', lastName: 'Muhammadaminov'),
  category: Category(title: 'Savdo va xizmat koʻrsatish'),
  district: District(name: 'Mirzo Ulugʻbek tumani'),
);

FuncController get _func => Get.find<FuncController>();

/// Sahifani eng "ogʻir" holatda quradi: uzun tuman nomi, katta son,
/// faol filtrlar va suratli eʼlonlar.
Future<void> _pumpHome(
  WidgetTester tester, {
  required double width,
  required double scale,
  required Brightness brightness,
  required bool grid,
}) async {
  final image = await tester.runAsync(
    () => createTestImage(width: 16, height: 10),
  );
  imageCache.clear();
  imageCache.putIfAbsent(
    const CachedNetworkImageProvider(_imageUrl),
    () => OneFrameImageStreamCompleter(
      SynchronousFuture(ImageInfo(image: image!)),
    ),
  );

  _func
    ..clearFilters()
    ..isGridView.value = grid
    ..isLoading.value = false
    ..hasMore.value = false;
  _func.totalPosts.value = 1234567;
  _func.posts.assignAll([for (var i = 0; i < 4; i++) _post(i)]);
  _func.userMe.value = me.UserMe(
    data: me.Data(
      district: me.District(name: 'Mirzo Ulugʻbek tumani, Qorasuv mavzesi'),
    ),
  );
  // Roʻyxatlar oldindan toʻldiriladi — varaq ochilganda tarmoqqa
  // murojaat qilinmaydi.
  _func.regions.assignAll([
    {'id': 1, 'name': 'Toshkent shahri'},
  ]);
  _func.categories.assignAll([
    {'id': 1, 'title': 'IT'},
  ]);
  _func.districts.assignAll([
    {'id': 11, 'name': 'Mirzo Ulugʻbek tumani'},
  ]);
  _func.selectedRegion.value = 1;
  _func.selectedDistrict.value = 11;

  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1;
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
      home: const Scaffold(body: SafeArea(child: MainContent())),
    ),
  );
  // Chiqish animatsiyalari tugashi uchun.
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _openFilters(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Filtr'));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = Directory.systemTemp.createTempSync('ishtopchi_home_');
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

  const widths = [320.0, 360.0, 392.7, 430.0, 768.0];
  const scales = [1.0, 1.3];

  for (final brightness in Brightness.values) {
    for (final scale in scales) {
      testWidgets('sahifa va filtr varagʻi sigʻadi — '
          'shrift ×$scale, ${brightness.name}', (tester) async {
        for (final width in widths) {
          for (final grid in [true, false]) {
            await _pumpHome(
              tester,
              width: width,
              scale: scale,
              brightness: brightness,
              grid: grid,
            );
            expect(
              tester.takeException(),
              isNull,
              reason: 'sahifa, ${width}dp, ${grid ? "katak" : "roʻyxat"}',
            );
          }

          await _openFilters(tester);
          expect(
            tester.takeException(),
            isNull,
            reason: 'filtr varagʻi, ${width}dp',
          );
        }
      });
    }
  }

  testWidgets('koʻrinish almashtirgichi katak va roʻyxatni tanlaydi', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      width: 392.7,
      scale: 1,
      brightness: Brightness.dark,
      grid: true,
    );

    await tester.tap(find.byTooltip('Ro‘yxat ko‘rinishi'));
    await tester.pump(const Duration(seconds: 1));
    expect(_func.isGridView.value, isFalse);
    expect(tester.takeException(), isNull);

    // Tanlangan variantni qayta bosish holatni oʻzgartirmaydi.
    await tester.tap(find.byTooltip('Ro‘yxat ko‘rinishi'));
    await tester.pump(const Duration(seconds: 1));
    expect(_func.isGridView.value, isFalse);

    await tester.tap(find.byTooltip('Katak ko‘rinishi'));
    await tester.pump(const Duration(seconds: 1));
    expect(_func.isGridView.value, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filtr tugmasida faol filtrlar soni chiqadi', (tester) async {
    await _pumpHome(
      tester,
      width: 392.7,
      scale: 1,
      brightness: Brightness.light,
      grid: true,
    );
    // Viloyat va tuman tanlangan.
    expect(find.text('2'), findsOneWidget);

    _func.jobType.value = 'REMOTE';
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('varaqdagi tanlov tugmalari tanlaydi va bekor qiladi', (
    tester,
  ) async {
    await _pumpHome(
      tester,
      width: 392.7,
      scale: 1,
      brightness: Brightness.dark,
      grid: true,
    );
    await _openFilters(tester);

    // Kartadagi yorliq ham shu matnda boʻlishi mumkin — varaqdagisi
    // daraxtda oxirgisi.
    Finder pill(String label) => find.text(label).last;

    await tester.tap(pill('Masofaviy ish'));
    await tester.pump();
    expect(_func.jobType.value, 'REMOTE');

    await tester.tap(pill('Kunlik ish'));
    await tester.pump();
    expect(_func.jobType.value, 'DAILY', reason: 'bitta tanlov qoladi');

    await tester.tap(pill('Kunlik ish'));
    await tester.pump();
    expect(_func.jobType.value, isNull, reason: 'qayta bosish bekor qiladi');

    await tester.ensureVisible(pill('Yarim stavka'));
    await tester.pump();
    await tester.tap(pill('Yarim stavka'));
    await tester.pump();
    expect(_func.employmentType.value, 'PART_TIME');

    // Yopish tugmasi varaqni yopadi, tanlovlar saqlanadi.
    await tester.tap(find.byTooltip('Close'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Filtrlash'), findsNothing);
    expect(_func.employmentType.value, 'PART_TIME');
    expect(tester.takeException(), isNull);
  });
}
