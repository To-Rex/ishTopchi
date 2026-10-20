import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ishtopchi/modules/main/views/skeleton_post_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../../common/widgets/app_ui.dart';
import '../../../common/widgets/post_card.dart';
import '../../../common/widgets/refresh_component.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../config/theme/app_theme.dart';
import '../../../controllers/api_controller.dart';
import '../../../controllers/funcController.dart';
import '../../../core/utils/breakpoints.dart';

/// Asosiy lenta: qidiruv, filtr paneli va eʼlonlar roʻyxati.
///
/// Ilgari butun ekran bitta 1200 qatorlik `build` metodida edi va har bir
/// maydonga `InputDecoration` qoʻlda yozilgan edi. Endi bezak mavzudan
/// keladi, qismlar esa alohida metodlarga ajratilgan.
///
/// `StatelessWidget` dan `StatefulWidget` ga oʻtkazildi: `RefreshController`
/// va `ScrollController` avval har bir qayta qurishda yangidan yaratilib,
/// hech qachon `dispose` qilinmasdi.
class MainContent extends StatefulWidget {
  const MainContent({super.key});

  @override
  State<MainContent> createState() => _MainContentState();
}

class _MainContentState extends State<MainContent> {
  final FuncController funcController = Get.find<FuncController>();
  final ApiController apiController = Get.find<ApiController>();
  final RefreshController refreshController = RefreshController(
    initialRefresh: false,
  );
  final ScrollController scrollController = ScrollController();

  /// Qidiruv soʻrovini kechiktirish taymeri.
  ///
  /// Har bir harfda soʻrov yuborilmaydi: yozish toʻxtagach bir marta
  /// yuboriladi. Avval har bosishda roʻyxat tozalanib, tarmoqqa yangi
  /// soʻrov ketardi va yozish paytida ekran qotib qolardi.
  Timer? _searchDebounce;

  /// Qidiruv matni. Boshlangʻich qiymat kontrollerdan olinadi — ekran
  /// qayta qurilganda yozilgan soʻz yoʻqolmaydi.
  late final TextEditingController _searchController = TextEditingController(
    text: funcController.searchQuery.value,
  );

  @override
  void dispose() {
    _searchDebounce?.cancel();
    refreshController.dispose();
    scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Refresh hodisasi
  Future<void> _onRefresh() async {
    funcController.currentPage.value = 1;
    funcController.hasMore.value = true;
    funcController.posts.clear();
    await apiController.fetchPosts(
      search: funcController.searchQuery.value,
      page: 1,
    );
    refreshController.refreshCompleted();
  }

  // Infinite scroll hodisasi
  Future<void> _onLoading() async {
    if (funcController.hasMore.value && !funcController.isLoading.value) {
      funcController.currentPage.value++;
      await apiController.fetchPosts(
        page: funcController.currentPage.value,
        search: funcController.searchQuery.value,
      );
    }
    refreshController.loadComplete();
  }

  /// Filtrlarni qoʻllagach lentani boshidan yuklash.
  Future<void> _reloadFromStart() async {
    funcController.currentPage.value = 1;
    funcController.posts.clear();
    funcController.hasMore.value = true;
    await apiController.fetchPosts(
      page: 1,
      search: funcController.searchQuery.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keng ekranda lenta chetdan chetga choʻzilmaydi — kartalar
    // oʻqiladigan ustunda qoladi. Telefonda hech narsa oʻzgarmaydi.
    return AppContentWidth(
      child: Column(
        children: [
          // Ilgari joylashuv, eʼlonlar soni, filtr va koʻrinish tugmasi
          // bitta qatorga tiqilgan edi — tuman nomi uzun boʻlsa, qolganlari
          // siqilib qolardi. Endi har birining oʻz joyi bor: qidiruv va
          // filtr bir qatorda, natija va koʻrinish ikkinchisida.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppReveal(child: _buildSearchRow(context)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 12),
            child: AppReveal(
              delay: AppReveal.step(1),
              child: _buildFeedHeader(context),
            ),
          ),
          Expanded(
            child: RefreshComponent(
              refreshController: refreshController,
              scrollController: scrollController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              enablePullUp: funcController.hasMore.value,
              // Roʻyxat toʻgʻridan-toʻgʻri `SmartRefresher` ga beriladi.
              // Ilgari bu yerda `Obx` turardi va paket kontentni aylanadigan
              // koʻrinish deb tanimasdi: roʻyxatni bitta slayverga oʻrab,
              // cheksiz balandlik berardi. Shuning uchun `ListView` ni
              // `shrinkWrap` bilan ishlatishga toʻgʻri kelardi va u barcha
              // kartalarni birdan qurardi. Endi slayverlar toʻgʻridan-toʻgʻri
              // beriladi — roʻyxat faqat koʻrinib turganini quradi.
              child: CustomScrollView(
                slivers: [
                  Obx(() {
                    if (funcController.isLoading.value &&
                        funcController.posts.isEmpty) {
                      return _buildList(
                        context,
                        itemCount: 6,
                        builder: (context, index) => const SkeletonPostCard(),
                      );
                    }

                    if (funcController.posts.isEmpty) {
                      return SliverToBoxAdapter(
                        child: AppEmptyState(
                          icon: LucideIcons.fileText,
                          title: 'Postlar mavjud emas'.tr,
                          message: 'Postlar topilmadi tavsifi'.tr,
                          actionLabel: 'Qayta yuklash'.tr,
                          actionIcon: const Icon(LucideIcons.refreshCw),
                          onAction: _onRefresh,
                        ),
                      );
                    }

                    return _buildList(
                      context,
                      itemCount: funcController.posts.length,
                      builder: (context, index) {
                        final post = funcController.posts[index];
                        return AppReveal(
                          delay: AppReveal.step(index),
                          child: PostCard(post: post, mePost: false),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Qidiruv matni oʻzgarganda lentani boshidan yuklash.
  ///
  /// Soʻrov kechiktiriladi: yozish davom etayotganda tarmoqqa hech narsa
  /// ketmaydi va roʻyxat bezovta qilinmaydi. Foydalanuvchi toʻxtagach
  /// (yoki "qidirish" tugmasini bosgach) natija bir marta yuklanadi.
  void _onSearchChanged(String value) {
    funcController.searchQuery.value = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => _loadSearchResults(value),
    );
  }

  /// Qidiruv natijalarini birinchi sahifadan yuklash.
  Future<void> _loadSearchResults(String value) async {
    funcController.currentPage.value = 1;
    funcController.hasMore.value = true;
    funcController.posts.clear();
    await apiController.fetchPosts(search: value, page: 1);
    refreshController.refreshCompleted();
  }

  /// Faol filtrlar soni — filtr tugmasidagi belgi uchun.
  int get _activeFilterCount =>
      [
        funcController.selectedRegion.value,
        funcController.selectedDistrict.value,
        funcController.selectedCategory.value,
        funcController.employmentType.value,
        funcController.sortPrice.value,
        funcController.minPrice.value,
        funcController.maxPrice.value,
        funcController.jobType.value,
      ].where((value) => value != null).length;

  /// Qidiruv maydoni va filtr tugmasi.
  Widget _buildSearchRow(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.5);

    // Filtr tugmasi qidiruv maydoni bilan bir balandlikda turadi — shrift
    // kattalashganda ham.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: Theme.of(context).textTheme.bodyLarge,
              textInputAction: TextInputAction.search,
              // Bezak mavzudagi `inputDecorationTheme` dan keladi.
              decoration: InputDecoration(
                hintText: 'Qidirish...'.tr,
                prefixIcon: Icon(LucideIcons.search, size: 19, color: muted),
                // Matn boʻlsa — tozalash tugmasi yumshoq paydo boʻladi.
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder:
                          (child, animation) => ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          ),
                      child:
                          value.text.isEmpty
                              ? const SizedBox.shrink()
                              : IconButton(
                                key: const ValueKey('clear'),
                                tooltip: 'Tozalash'.tr,
                                icon: Icon(
                                  LucideIcons.x,
                                  size: 17,
                                  color: muted,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchDebounce?.cancel();
                                  funcController.searchQuery.value = '';
                                  _loadSearchResults('');
                                },
                              ),
                    );
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 15,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => _FilterButton(
              activeCount: _activeFilterCount,
              onTap: () => _showFilterDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Eʼlonlar soni, joylashuv va koʻrinish almashtirgichi.
  Widget _buildFeedHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.55);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(
                () => _AnimatedCount(
                  value: funcController.totalPosts.value,
                  suffix: 'ta e’lon'.tr,
                ),
              ),
              const SizedBox(height: 3),
              Obx(
                () => Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 13, color: muted),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        funcController.userMe.value.data?.district?.name ??
                            'Viloyat'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.5,
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Obx(
          () => _ViewToggle(
            isGrid: funcController.isGridView.value,
            onChanged: (grid) => funcController.isGridView.value = grid,
          ),
        ),
      ],
    );
  }

  /// Eʼlonlar roʻyxati — katak yoki roʻyxat koʻrinishida.
  ///
  /// Slayver qaytaradi: u `SmartRefresher` ning oʻz aylanadigan koʻrinishiga
  /// qoʻshiladi va roʻyxat dangasa (lazy) boʻlib qoladi — faqat koʻrinib
  /// turgan kartalar quriladi.
  ///
  /// `isGridView` shu yerda oʻqiladi: chaqiruv `Obx` ichida boʻlgani uchun
  /// koʻrinish almashganda roʻyxat qayta quriladi.
  Widget _buildList(
    BuildContext context, {
    required int itemCount,
    required Widget Function(BuildContext, int) builder,
  }) {
    // Yuklash paneli oʻchirilgan boʻlsa, oxirgi karta suzuvchi pastki
    // panel ostida qolmasligi uchun uning balandligicha boʻshliq.
    final bottomInset =
        funcController.hasMore.value
            ? 0.0
            : MediaQuery.paddingOf(context).bottom;
    final padding = EdgeInsets.fromLTRB(8, 0, 8, 16 + bottomInset);

    final sliver =
        funcController.isGridView.value
            ? SliverGrid(
              gridDelegate: PostCard.gridDelegate(context),
              delegate: SliverChildBuilderDelegate(
                builder,
                childCount: itemCount,
              ),
            )
            : SliverList(
              delegate: SliverChildBuilderDelegate(
                builder,
                childCount: itemCount,
              ),
            );

    return SliverPadding(padding: padding, sliver: sliver);
  }

  // ── Filtr varagʻi ──────────────────────────────────────────────────

  /// Ish turlari: API qiymati va yorligʻi.
  ///
  /// Yorliqlar eʼlon kartasidagi bilan bir xil. Avval filtrda `FULL_TIME`
  /// "kunlik", `TEMPORARY` esa "Yarim kunlik" deb koʻrsatilardi — kartadagi
  /// yozuvga toʻgʻri kelmasdi.
  static const List<(String, String)> _jobTypes = [
    ('FULL_TIME', 'To‘liq ish kuni'),
    ('TEMPORARY', 'Vaqtinchalik ish'),
    ('REMOTE', 'Masofaviy ish'),
    ('DAILY', 'Kunlik ish'),
    ('PROJECT_BASED', 'Loyihaviy ish'),
    ('INTERNSHIP', 'Amaliyot'),
  ];

  /// Bandlik turlari — eʼlon sahifasidagi yorliqlar bilan bir xil.
  static const List<(String, String)> _employmentTypes = [
    ('FULL_TIME', 'To‘liq ish kuni'),
    ('PART_TIME', 'Yarim stavka'),
    ('SHIFT_BASED', 'Smenali ish'),
    ('FLEXIBLE', 'Moslashuvchan ish'),
    ('REGULAR_SCHEDULE', 'Doimiy jadval'),
  ];

  /// "Qoʻllash" bosilgandan keyin lenta yuklanayotgani.
  final RxBool _applyingFilters = false.obs;

  void _showFilterDialog(BuildContext context) {
    // Roʻyxatlar hali yuklanmagan boʻlsa — yuklab olamiz.
    if (funcController.regions.isEmpty) {
      apiController.fetchRegions().then((regions) {
        funcController.regions.assignAll(regions);
        if (regions.isNotEmpty && funcController.selectedRegion.value == null) {
          funcController.selectedRegion.value = regions.first['id'] as int;
          apiController
              .fetchDistricts(funcController.selectedRegion.value!)
              .then((districts) {
                funcController.districts.assignAll(districts);
                if (districts.isNotEmpty &&
                    funcController.selectedDistrict.value == null) {
                  funcController.selectedDistrict.value =
                      districts.first['id'] as int;
                }
              });
        }
      });
    }
    if (funcController.categories.isEmpty) {
      apiController.fetchCategories().then((categories) {
        funcController.categories.assignAll(categories);
      });
    }

    // Markazdagi oyna oʻrniga pastdan chiqadigan varaq: bosh barmoq
    // yetadigan joyda, roʻyxat uzun boʻlsa ham tugmalar koʻrinib turadi.
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _buildFilterSheet(context),
    );
  }

  Widget _buildFilterSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final media = MediaQuery.of(context);

    return Padding(
      // Klaviatura ochilganda varaq uning ustiga koʻtariladi.
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 10, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filtrlash'.tr,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip:
                        MaterialLocalizations.of(context).closeButtonTooltip,
                    icon: Icon(
                      LucideIcons.x,
                      size: 20,
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSectionLabel(text: 'Joylashuv'.tr),
                      _buildRegionDropdown(),
                      const SizedBox(height: 12),
                      // Tumanlar yuklanayotganda maydon oʻrnida yumshoq
                      // almashuvchi yuklanish belgisi.
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child:
                            funcController.isLoadingDistricts.value
                                ? SizedBox(
                                  key: const ValueKey('loading'),
                                  height: AppDimensions.buttonHeight,
                                  child: Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                )
                                : KeyedSubtree(
                                  key: const ValueKey('districts'),
                                  child: _buildDistrictDropdown(),
                                ),
                      ),
                      const SizedBox(height: 26),
                      AppSectionLabel(text: 'Maosh'.tr),
                      _buildPriceFields(theme),
                      const SizedBox(height: 26),
                      AppSectionLabel(text: 'Ish turi'.tr),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (value, label) in _jobTypes)
                            _ChoicePill(
                              label: label.tr,
                              selected: funcController.jobType.value == value,
                              // Tanlangan tugmani qayta bosish tanlovni
                              // bekor qiladi.
                              onTap:
                                  () =>
                                      funcController.jobType.value =
                                          funcController.jobType.value == value
                                              ? null
                                              : value,
                            ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      AppSectionLabel(text: 'Bandlik turi'.tr),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final (value, label) in _employmentTypes)
                            _ChoicePill(
                              label: label.tr,
                              selected:
                                  funcController.employmentType.value == value,
                              onTap:
                                  () =>
                                      funcController.employmentType.value =
                                          funcController.employmentType.value ==
                                                  value
                                              ? null
                                              : value,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Harakatlar paneli — varaq aylantirilganda ham joyida qoladi.
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.onSurface.withValues(alpha: 0.07),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  12 + media.viewPadding.bottom,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Tozalash'.tr,
                        onPressed: () {
                          funcController.clearFilters();
                          _reloadFromStart();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(
                        () => AppButton(
                          label: "Qo'llash".tr,
                          filled: true,
                          loading: _applyingFilters.value,
                          onPressed: () async {
                            if (_applyingFilters.value) return;
                            _applyingFilters.value = true;
                            try {
                              await _reloadFromStart();
                            } finally {
                              _applyingFilters.value = false;
                            }
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionDropdown() {
    return _buildDropdown<int>(
      label: 'Viloyat'.tr,
      value: funcController.selectedRegion.value,
      items:
          funcController.regions
              .map(
                (region) => DropdownMenuItem<int>(
                  value: region['id'] as int,
                  child: Text(region['name'].toString(), maxLines: 1),
                ),
              )
              .toList(),
      onChanged: (value) async {
        if (value != null) {
          funcController.selectedRegion.value = value;
          funcController.districts.clear();
          funcController.selectedDistrict.value = null;
          funcController.isLoadingDistricts.value = true;
          final districts = await apiController.fetchDistricts(value);
          funcController.districts.assignAll(districts);
          funcController.isLoadingDistricts.value = false;
          if (districts.isNotEmpty) {
            funcController.selectedDistrict.value =
                districts.first['id'] as int;
          }
        }
      },
      validator:
          (value) => value == null ? 'Iltimos, viloyatni tanlang'.tr : null,
    );
  }

  Widget _buildDistrictDropdown() {
    return _buildDropdown<int>(
      label: 'Shahar/Tuman'.tr,
      value: funcController.selectedDistrict.value,
      items:
          funcController.districts
              .map(
                (district) => DropdownMenuItem<int>(
                  value: district['id'] as int,
                  child: Text(district['name'].toString(), maxLines: 1),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          funcController.selectedDistrict.value = value;
        }
      },
      validator:
          (value) =>
              value == null ? 'Iltimos, shahar/tumanni tanlang'.tr : null,
    );
  }

  /// "Narxdan" va "Narxgacha" — yonma-yon, bitta boʻlimda.
  Widget _buildPriceFields(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: funcController.minPrice.value,
            keyboardType: TextInputType.number,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Narxdan'.tr,
              suffixText: 'UZS',
            ),
            onChanged:
                (value) =>
                    funcController.minPrice.value =
                        value.isEmpty ? null : value,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final numValue = double.tryParse(value);
                if (numValue == null || numValue < 0) {
                  return "Iltimos, to'g'ri narx kiriting".tr;
                }
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            initialValue: funcController.maxPrice.value,
            keyboardType: TextInputType.number,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Narxgacha'.tr,
              suffixText: 'UZS',
            ),
            onChanged:
                (value) =>
                    funcController.maxPrice.value =
                        value.isEmpty ? null : value,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final numValue = double.tryParse(value);
                if (numValue == null || numValue < 0) {
                  return "Iltimos, to'g'ri narx kiriting".tr;
                }
                final minPriceValue =
                    funcController.minPrice.value != null
                        ? double.tryParse(funcController.minPrice.value!)
                        : null;
                if (minPriceValue != null && numValue < minPriceValue) {
                  return "Narxgacha narxdan katta bo'lishi kerak".tr;
                }
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  /// Filtr oynasidagi tanlov maydoni.
  ///
  /// Toʻrtta dropdown avval bir xil 60 qatorlik bezak bilan takrorlangan
  /// edi; bezak endi mavzudan keladi.
  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DropdownButtonFormField2<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 240,
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? colors.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        offset: const Offset(0, -6),
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          LucideIcons.chevronDown,
          size: 18,
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
      ),
      style: theme.textTheme.bodyMedium,
      items: items,
      onChanged: onChanged,
      validator: validator,
      hint: Text(
        'Tanlang'.tr,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.42),
        ),
      ),
    );
  }
}

/// Raqamni uchtalab guruhlaydi: 12345 → 12 345.
///
/// Uzilmas boʻshliq (U+00A0) — raqam ikki qatorga boʻlinib ketmaydi. Tor
/// boʻshliq (U+202F) ishlatilmadi: koʻp shriftlarda u yoʻq.
String _groupDigits(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Eʼlonlar soni — qiymat oʻzgarganda raqam yumshoq sanalib boradi.
class _AnimatedCount extends StatelessWidget {
  const _AnimatedCount({required this.value, required this.suffix});

  final int value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value.toDouble()),
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, current, _) {
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _groupDigits(current.round()),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                  // Raqamlar bir xil kenglikda — sanalayotganda matn
                  // titramaydi.
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              TextSpan(
                text: '  $suffix',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}

/// Qidiruv yonidagi filtr tugmasi.
///
/// Filtr faol boʻlsa tugma urgʻu rangiga oʻtadi va burchagida faol
/// filtrlar soni chiqadi — avvalgi kichik nuqtadan aniqroq.
class _FilterButton extends StatefulWidget {
  const _FilterButton({required this.activeCount, required this.onTap});

  final int activeCount;
  final VoidCallback onTap;

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final input = theme.inputDecorationTheme;
    final active = widget.activeCount > 0;
    final radius = BorderRadius.circular(AppTheme.radiusControl);

    // Faol boʻlmaganda qidiruv maydoni bilan bir xil koʻrinadi.
    final idleFill = input.fillColor ?? colors.surfaceContainer;
    final idleBorder =
        input.enabledBorder?.borderSide.color ??
        colors.onSurface.withValues(alpha: 0.2);

    return Tooltip(
      message: 'Filtr'.tr,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          width: 54,
          decoration: BoxDecoration(
            color: active ? colors.primary : idleFill,
            borderRadius: radius,
            border: Border.all(
              color: active ? colors.primary : idleBorder,
              width: 1.2,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _setPressed(true),
              onTapUp: (_) => _setPressed(false),
              onTapCancel: () => _setPressed(false),
              borderRadius: radius,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  TweenAnimationBuilder<Color?>(
                    tween: ColorTween(
                      end:
                          active
                              ? colors.onPrimary
                              : colors.onSurface.withValues(alpha: 0.75),
                    ),
                    duration: const Duration(milliseconds: 240),
                    builder:
                        (context, color, _) => Icon(
                          LucideIcons.slidersHorizontal,
                          size: 20,
                          color: color,
                        ),
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: AnimatedScale(
                      scale: active ? 1 : 0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutBack,
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 16),
                        height: 16,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors.onPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${widget.activeCount}',
                          textScaler: TextScaler.noScaling,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Katak / roʻyxat almashtirgichi.
///
/// Avval bitta tugma edi va ikonkasi *keyingi* holatni koʻrsatardi —
/// hozirgi koʻrinish qaysi ekani bilinmasdi. Endi ikkala variant ham
/// koʻrinadi, tanlangani ostida urgʻu foni sirpanib oʻtadi.
class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.isGrid, required this.onChanged});

  final bool isGrid;
  final ValueChanged<bool> onChanged;

  static const double _segment = 40;
  static const double _height = 34;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const radius = BorderRadius.all(Radius.circular(10));

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.08)),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            left: isGrid ? 0 : _segment,
            top: 0,
            bottom: 0,
            width: _segment,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: radius,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _segmentButton(
                context,
                icon: LucideIcons.layoutGrid,
                selected: isGrid,
                tooltip: 'Katak ko‘rinishi'.tr,
                onTap: () => onChanged(true),
              ),
              _segmentButton(
                context,
                icon: LucideIcons.list,
                selected: !isGrid,
                tooltip: 'Ro‘yxat ko‘rinishi'.tr,
                onTap: () => onChanged(false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segmentButton(
    BuildContext context, {
    required IconData icon,
    required bool selected,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: selected ? null : onTap,
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: _segment,
            height: _height,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end:
                    selected
                        ? colors.onPrimary
                        : colors.onSurface.withValues(alpha: 0.55),
              ),
              duration: const Duration(milliseconds: 220),
              builder:
                  (context, color, _) => Icon(icon, size: 17, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

/// Filtr varagʻidagi tanlov tugmasi.
class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(12);
    final foreground =
        selected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.8);

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color:
              selected
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.04),
          borderRadius: radius,
          border: Border.all(
            color:
                selected
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.12),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Belgi faqat tanlanganda chiqadi va matnni yumshoq suradi.
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child:
                        selected
                            ? Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                LucideIcons.check,
                                size: 15,
                                color: foreground,
                              ),
                            )
                            : const SizedBox.shrink(),
                  ),
                  // `AnimatedDefaultTextStyle` uslubni toʻliq almashtiradi,
                  // shuning uchun asos mavzudan olinadi — aks holda shrift
                  // oilasi yoʻqolardi.
                  Flexible(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: (theme.textTheme.labelLarge ?? const TextStyle())
                          .copyWith(
                            fontSize: 13.5,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                            color: foreground,
                          ),
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
