// Eʼlon kartasi (katak va roʻyxat koʻrinishida) hech qachon toshib
// ketmasligi kerak.
//
// Foydalanuvchi telefonda "A RenderFlex overflowed by 10 pixels on the
// bottom" xatosini koʻrgan (post_card.dart, katak koʻrinishi). Sabab:
// katak balandligi qatʼiy nisbatdan (`kenglik / 0.59`) olinardi, matn
// esa kenglikka qarab qisqarmaydi — tor ekranda yoki shrift
// kattalashtirilganda matnga joy yetmay qolardi.
//
// Ikkinchi xato: katakdan roʻyxatga oʻtganda "RenderBox was not laid out"
// (main_content.dart, ListView). Roʻyxat koʻrinishi `IntrinsicHeight`
// bilan qurilgan edi; u suratdan tabiiy balandligini soʻraydi, surat esa
// `height: double.infinity` bilan berilgan — javob cheksiz chiqardi.
// Surat yuklanmaguncha bu bilinmasdi; katakda koʻrilgan suratlar esa
// keshdan darhol chiqadi, shuning uchun roʻyxatga oʻtish bilan yiqilardi.
//
// Bu test haqiqiy [PostCard] ni eng "ogʻir" mazmun bilan (uzun sarlavha,
// ikki qatorli tavsif, uzun ism) va **yuklangan surat** bilan turli ekran
// kengliklari va shrift oʻlchamlarida chizadi va birorta ham xato
// boʻlmasligini tekshiradi.

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart' hide Data;
import 'package:ishtopchi/common/widgets/post_card.dart';
import 'package:ishtopchi/config/theme/app_theme.dart';
import 'package:ishtopchi/controllers/api_controller.dart';
import 'package:ishtopchi/controllers/funcController.dart';
import 'package:ishtopchi/core/models/post_model.dart';
import 'package:ishtopchi/modules/main/views/skeleton_post_card.dart';

const _imageUrl = 'https://example.test/vacancy.jpg';

/// Suratni xotira keshiga joylaydi — xuddi katakda allaqachon koʻrilgan
/// surat kabi. Shunda `Image` uni tarmoqsiz va **darhol** oladi.
Future<void> _primeImageCache(WidgetTester tester) async {
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
}

/// Eng koʻp joy egallaydigan eʼlon: har bir matn maydoni chegarasigacha.
Data _heavyPost(int id) {
  return Data(
    id: id,
    // Juft eʼlonlarda surat bor (keshdan yuklangan), toqlarida yoʻq —
    // ikkala holat ham tekshiriladi.
    pictureUrl: id.isEven ? _imageUrl : null,
    title: 'Katta savdo markaziga tajribali sotuvchi-konsultant kerak',
    content:
        'Mijozlar bilan ishlash, tovarlarni joylashtirish, kassa bilan '
        'ishlash va hisobot yuritish. Tajriba talab qilinadi.',
    salaryFrom: '12000000',
    salaryTo: '18000000',
    views: 12345,
    jobType: 'PROJECT_BASED',
    createdAt: '2026-09-30T10:00:00Z',
    user: User(firstName: 'Abdulazizxon', lastName: 'Muhammadaminov'),
    category: Category(title: 'Savdo va xizmat koʻrsatish'),
    district: District(name: 'Mirzo Ulugʻbek tumani'),
  );
}

Future<void> _pumpFeed(
  WidgetTester tester, {
  required double width,
  required double textScale,
  required bool mePost,
  required Brightness brightness,
  required bool grid,
}) async {
  // Kartalar ham, ekranlar ham shu belgiga qarab koʻrinishni tanlaydi.
  Get.find<FuncController>().isGridView.value = grid;

  tester.view.physicalSize = Size(width, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, 2000),
        textScaler: TextScaler.linear(textScale),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme:
            brightness == Brightness.dark
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
        // Ilovadagi kabi: MaterialApp MediaQuery ni oʻzi qayta quradi,
        // shuning uchun shrift oʻlchami builder orqali beriladi.
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(textScale)),
              child: child!,
            ),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              // 4 ta haqiqiy karta va 2 ta yuklanish skeleti — skelet ham
              // aynan shu kataklarga tushadi.
              Widget item(BuildContext context, int index) =>
                  index < 4
                      ? PostCard(post: _heavyPost(index), mePost: mePost)
                      : const SkeletonPostCard();

              return Obx(
                () =>
                    Get.find<FuncController>().isGridView.value
                        ? GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: PostCard.gridDelegate(
                            context,
                            mePost: mePost,
                          ),
                          itemCount: 6,
                          itemBuilder: item,
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: 6,
                          itemBuilder: item,
                        ),
              );
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // `FuncController` ichida `GetStorage()` bor, u esa papkani
    // `path_provider` dan soʻraydi. Testda platforma kanali yoʻq,
    // shuning uchun kanal vaqtinchalik papkani qaytaradi.
    final dir = Directory.systemTemp.createTempSync('ishtopchi_test_');
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

  // Haqiqiy telefonlar: kichik Android, iPhone, keng Android, Pro Max;
  // soʻng planshet chegarasi va planshet.
  const widths = [320.0, 360.0, 375.0, 393.0, 411.0, 430.0, 600.0, 768.0];

  // 1.0 — standart, 1.3 — ilova ruxsat beradigan eng katta shrift.
  const scales = [1.0, 1.15, 1.3];

  for (final grid in [true, false]) {
    for (final mePost in [false, true]) {
      for (final scale in scales) {
        for (final brightness in Brightness.values) {
          testWidgets('${grid ? "katak" : "roʻyxat"} toshmaydi — '
              '${mePost ? "mening eʼlonim" : "lenta"}, '
              'shrift ×$scale, ${brightness.name}', (tester) async {
            await _primeImageCache(tester);
            for (final width in widths) {
              await _pumpFeed(
                tester,
                width: width,
                textScale: scale,
                mePost: mePost,
                brightness: brightness,
                grid: grid,
              );

              expect(
                tester.takeException(),
                isNull,
                reason: 'kenglik ${width.toInt()}dp da toshish boʻldi',
              );
            }
          });
        }
      }
    }
  }

  testWidgets('katakdan roʻyxatga va qaytib oʻtish yiqilmaydi', (tester) async {
    await _primeImageCache(tester);

    // Foydalanuvchi qurilmasining kengligi (392.7dp).
    await _pumpFeed(
      tester,
      width: 392.7,
      textScale: 1.0,
      mePost: false,
      brightness: Brightness.dark,
      grid: true,
    );
    expect(tester.takeException(), isNull, reason: 'katak');

    Get.find<FuncController>().isGridView.value = false;
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'katak → roʻyxat');

    Get.find<FuncController>().isGridView.value = true;
    await tester.pump();
    expect(tester.takeException(), isNull, reason: 'roʻyxat → katak');
  });

  testWidgets('roʻyxat kartasi: maosh guruhlangan, sana nisbiy', (
    tester,
  ) async {
    Get.find<FuncController>().isGridView.value = false;
    final now = DateTime.now();
    // Toʻrttala karta ham bir vaqtda ekranda boʻlsin.
    tester.view.physicalSize = const Size(420, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Data post(int id, {required Duration age, User? user}) => Data(
      id: id,
      title: 'Eʼlon $id',
      salaryFrom: '9000000',
      salaryTo: '14000000',
      views: 12345,
      createdAt: now.subtract(age).toIso8601String(),
      user: user,
      district: District(name: 'Yunusobod tumani'),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: ListView(
            children: [
              PostCard(
                post: post(
                  1,
                  age: Duration.zero,
                  user: User(firstName: 'Aziz', lastName: 'Karimov'),
                ),
                mePost: false,
              ),
              PostCard(
                post: post(2, age: const Duration(days: 1)),
                mePost: false,
              ),
              PostCard(
                post: post(3, age: const Duration(days: 3)),
                mePost: false,
              ),
              PostCard(
                post: post(4, age: const Duration(days: 15)),
                mePost: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('9 000 000 – 14 000 000 UZS'), findsNWidgets(4));
    expect(find.text('12 345 ko‘rish'), findsNWidgets(4));
    expect(find.text('Bugun'), findsOneWidget);
    expect(find.text('Kecha'), findsOneWidget);
    expect(find.text('3 kun oldin'), findsOneWidget);
    expect(find.text('2 hafta oldin'), findsOneWidget);
    // Ism boʻlmasa, ish beruvchi qatori umuman chiqmaydi.
    expect(find.text('Aziz Karimov'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
