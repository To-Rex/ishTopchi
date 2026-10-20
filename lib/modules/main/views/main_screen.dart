import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/glass_tab_bar.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../controllers/theme_controller.dart';
import '../../ad_posting/views/ad_posting_screen.dart';
import '../../messages/views/messages_screen.dart';
import '../../profile/views/profile_screen.dart';
import 'main_content.dart';

/// Ilovaning karkasi: yuqori panel, boʻlimlar va pastki navigatsiya.
///
/// Yuqori panel avval `PreferredSize` ichidagi `margin-top: 80` bilan
/// qurilgan edi — status paneli balandligi qoʻlda taxmin qilingan.
/// Endi oddiy [AppBar]: u chekkalarni oʻzi hisoblaydi va mavzudagi
/// `appBarTheme` ga boʻysunadi.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Pastki paneldagi boʻlimlar — avvalgidek toʻrtta, oʻsha tartibda.
  static const List<GlassTab> _tabs = [
    GlassTab(LucideIcons.house, LucideIcons.house500, 'Asosiy'),
    GlassTab(
      LucideIcons.circlePlus,
      LucideIcons.circlePlus500,
      'E’lon qo‘shish',
    ),
    GlassTab(
      LucideIcons.messageCircle,
      LucideIcons.messageCircle500,
      'Xabarlar',
    ),
    GlassTab(LucideIcons.user, LucideIcons.user500, 'Profil'),
  ];

  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();
  final ThemeController themeController = Get.find<ThemeController>();

  /// Boʻlimlar bir marta quriladi: ilgari ular har bir qayta qurishda
  /// yangidan yaratilardi va `IndexedStack` ularni qaytadan qurishga
  /// majbur boʻlardi.
  late final List<Widget> _pages = [
    const MainContent(),
    const AdPostingScreen(),
    MessagesScreen(),
    ProfileScreen(),
  ];

  /// Bir marta ochilgan boʻlimlar.
  ///
  /// `IndexedStack` avval barcha toʻrttasini birdan qurardi: xarita,
  /// suhbatlar va profil ilova ochilishida tayyorlanardi — sovuq start
  /// shu sababdan sekin edi. Endi boʻlim faqat birinchi marta bosilganda
  /// quriladi va keyin tirik qoladi (holat, scroll va forma saqlanadi).
  final Set<int> _visited = <int>{0};

  @override
  void initState() {
    super.initState();
    // FCM tokenini yozib qoʻyamiz (bir marta).
    funcController.logFcmToken();

    // Foydalanuvchi ma'lumotlarini yuklash. Ilgari bu `build` ichida
    // edi — har bir qayta qurishda tarmoqqa soʻrov ketardi.
    if (funcController.globalToken.value.isNotEmpty) {
      apiController.getMe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kontent pastki panel ostidan ham oʻtadi — panel shisha kabi
      // xiralashtirib koʻrsatadi. Roʻyxatlar oxiriga panel balandligicha
      // boʻshliq qoʻshilgan (`MediaQuery.paddingOf(context).bottom`),
      // shuning uchun oxirgi element panel ostida qolib ketmaydi.
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 12,
        title: _Wordmark(onTap: () => funcController.setBarIndex(0)),
        actions: [
          // Mavzu almashtirish faqat profil boʻlimida koʻrinadi —
          // avvalgidek.
          Obx(
            () =>
                funcController.barIndex.value == 3
                    ? IconButton(
                      icon: Icon(
                        themeController.isDarkMode.value
                            ? LucideIcons.sun
                            : LucideIcons.moon,
                      ),
                      onPressed: () => themeController.toggleTheme(),
                      tooltip:
                          themeController.isDarkMode.value
                              ? 'Yorqin mavzu'
                              : 'Tungi mavzu',
                    )
                    : const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(LucideIcons.heart),
            onPressed: () => Get.toNamed('/favorites'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Obx(() {
        final index = funcController.barIndex.value;
        _visited.add(index);

        return IndexedStack(
          index: index,
          children: [
            for (var i = 0; i < _pages.length; i++)
              if (_visited.contains(i))
                // Koʻrinmayotgan boʻlimda animatsiyalar (masalan, xarita
                // siljishi) toʻxtaydi — orqa fonda kadr talab qilmaydi.
                TickerMode(enabled: i == index, child: _pages[i])
              else
                const SizedBox.shrink(),
          ],
        );
      }),
      bottomNavigationBar: Obx(
        () => GlassTabBar(
          tabs: _tabs,
          currentIndex: funcController.barIndex.value,
          onSelect: funcController.setBarIndex,
        ),
      ),
    );
  }
}

/// Yuqori paneldagi brend nomi. Bosilganda birinchi boʻlimga qaytaradi.
class _Wordmark extends StatelessWidget {
  const _Wordmark({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.briefcaseBusiness,
                size: 21,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 9),
              Text(
                'Ishtopchi',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 19,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
