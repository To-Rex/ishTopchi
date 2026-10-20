import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../controllers/api_controller.dart';
import '../../controllers/funcController.dart';
import '../../core/models/post_model.dart';
import '../../modules/main/views/post_detail_screen.dart';

/// Eʼlon kartasi — lenta, saralanganlar va "mening eʼlonlarim" ekranlarida.
///
/// Ikki koʻrinishi bor: roʻyxat va katak. Ilgari ikkalasi deyarli bir xil
/// 400 qatordan iborat edi; endi mazmun bitta joyda quriladi, koʻrinish
/// esa faqat joylashuvni belgilaydi.
class PostCard extends StatelessWidget {
  /// `Data` yoki `WishList` — ikkalasi ham bir xil maydonlarni beradi,
  /// shuning uchun tip ataylab ochiq qoldirilgan (avvalgidek).
  final dynamic post;

  final bool mePost;

  const PostCard({super.key, required this.post, required this.mePost});

  /// Surat nisbati katak koʻrinishida.
  static const double _mediaAspectRatio = 16 / 10;

  /// Roʻyxat koʻrinishidagi kvadrat suratning oʻlchami.
  static const double _thumbSize = 76;

  // Kartadagi qatʼiy oʻlchamlar. Ular kartani chizishda ham, katak
  // balandligini hisoblashda ham ishlatiladi — ikkisi ajralib qolmasin.
  static const EdgeInsets _bodyPadding = EdgeInsets.all(12);
  static const EdgeInsets _chipPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 4,
  );
  static const double _gapS = 8;
  static const double _gapM = 10;
  static const double _gapL = 12;
  static const double _footerGap = 6;
  static const double _avatarRadius = 11;
  static const double _metaIconSize = 13;

  /// Katak koʻrinishi uchun delegat.
  ///
  /// Katak balandligi taxmin qilinmaydi: mazmun joriy shrift oʻlchami va
  /// mavzu uslublari bilan **oʻlchanadi**. Shuning uchun karta istalgan
  /// ekran kengligida va shrift kattaligida sigʻadi.
  static SliverGridDelegate gridDelegate(
    BuildContext context, {
    bool mePost = false,
  }) {
    const shell = _CardShell.inset;
    const border = _CardShell.borderWidth * 2;

    return AppTileGridDelegate(
      maxTileWidth: AppBreakpoints.tileExtent,
      fixedColumns: AppBreakpoints.fixedGridColumns(context),
      mediaAspectRatio: _mediaAspectRatio,
      mediaInset: shell.horizontal + border,
      // +1 — kasr piksellarni yaxlitlashdagi farq uchun.
      extraHeight:
          shell.vertical +
          border +
          _gridBodyHeight(context, mePost: mePost) +
          1,
    );
  }

  /// Katakdagi mazmun (suratdan pastdagi qism) balandligi.
  ///
  /// Eng ogʻir holat olinadi: tavsif ikki qator. Mazmun qisqaroq
  /// boʻlsa, ortgan joy muallif qatori ustiga tushadi.
  /// Oʻlchov natijalari keshi.
  ///
  /// `TextPainter.layout()` har bir qayta qurishda ~10 marta ishlaydi,
  /// natija esa mavzu va shrift oʻlchamiga bogʻliq — ular oʻzgarmaguncha
  /// bir xil qoladi.
  static final Map<String, double> _bodyHeightCache = <String, double>{};

  static double _gridBodyHeight(BuildContext context, {required bool mePost}) {
    final theme = Theme.of(context);
    final cacheKey =
        '${theme.hashCode}|'
        '${MediaQuery.textScalerOf(context).scale(10)}|'
        '${theme.textTheme.bodyMedium?.fontSize}|'
        '${theme.textTheme.bodyMedium?.height}|'
        '${theme.textTheme.bodyMedium?.fontFamily}|'
        '$mePost';

    final cached = _bodyHeightCache[cacheKey];
    if (cached != null) return cached;

    double line(TextStyle? style, [int lines = 1]) =>
        _textHeight(context, style, lines: lines);

    final summary =
        line(_titleStyle(theme, compact: true)) +
        _gapS +
        math.max(
          line(_chipStyle(theme)) + _chipPadding.vertical,
          line(_jobTypeStyle(theme)),
        ) +
        _gapM +
        line(_descriptionStyle(theme), 2) +
        _gapL +
        line(_salaryStyle(theme)) +
        _gapS +
        math.max(_metaIconSize, line(_metaStyle(theme)));

    final footer =
        math.max(_avatarRadius * 2, line(_authorNameStyle(theme))) +
        _footerGap +
        line(_statStyle(theme)) +
        (mePost ? _gapL + _editButtonHeight(context) : 0);

    final height = _bodyPadding.vertical + summary + _gapM + footer;
    if (_bodyHeightCache.length > 32) _bodyHeightCache.clear();
    return _bodyHeightCache[cacheKey] = height;
  }

  /// Matnning haqiqiy balandligi — `Text` uni qanday chizsa, shunday.
  static double _textHeight(
    BuildContext context,
    TextStyle? style, {
    int lines = 1,
  }) {
    // Karta ichidagi `Material` standart uslubni `bodyMedium` ga
    // oʻrnatadi, `Text` esa oʻz uslubini shunga qoʻshadi. Hisob ham
    // aynan shunday qilinadi.
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final painter = TextPainter(
      text: TextSpan(
        text: List.filled(lines, 'Ag').join('\n'),
        style: base.merge(style),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: lines,
    )..layout();
    final height = painter.height;
    painter.dispose();
    return height;
  }

  /// Tahrirlash tugmasi shrift bilan birga oʻsadi.
  static double _editButtonHeight(BuildContext context) =>
      math.max(38.0, _textHeight(context, _editLabelStyle) + 16);

  // ── Matn uslublari ───────────────────────────────────────────────
  static Color _muted(ThemeData theme) =>
      theme.colorScheme.onSurface.withValues(alpha: 0.6);

  static TextStyle? _titleStyle(ThemeData theme, {required bool compact}) =>
      theme.textTheme.titleMedium?.copyWith(fontSize: compact ? 15 : 16);

  static TextStyle _chipStyle(ThemeData theme) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: theme.colorScheme.primary,
  );

  static TextStyle? _jobTypeStyle(ThemeData theme) =>
      theme.textTheme.bodySmall?.copyWith(fontSize: 11.5, color: _muted(theme));

  static TextStyle? _descriptionStyle(ThemeData theme) => theme
      .textTheme
      .bodySmall
      ?.copyWith(fontSize: 12.5, height: 1.35, color: _muted(theme));

  static TextStyle? _salaryStyle(ThemeData theme) => theme.textTheme.titleSmall
      ?.copyWith(fontSize: 13.5, color: theme.colorScheme.primary);

  static TextStyle? _metaStyle(ThemeData theme) =>
      theme.textTheme.bodySmall?.copyWith(fontSize: 12, color: _muted(theme));

  static TextStyle? _authorNameStyle(ThemeData theme) =>
      theme.textTheme.bodySmall?.copyWith(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.onSurface,
      );

  static TextStyle? _statStyle(ThemeData theme) =>
      theme.textTheme.bodySmall?.copyWith(fontSize: 10.5, color: _muted(theme));

  static const TextStyle _editLabelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.find<ApiController>();
    final FuncController funcController = Get.find<FuncController>();

    // Koʻrinish rejimi shu yerda reaktiv kuzatilmaydi: roʻyxatni oʻzi
    // qurgan ekran (`Obx`) rejim almashganda kartalarni baribir qayta
    // quradi. Ilgari har bir karta alohida `Obx` ochib, oʻsha signalga
    // obuna boʻlardi — kartalar soniga proporsional ortiqcha ish.
    return funcController.isGridView.value
        ? _CardShell(
          onTap: () => _openDetail(),
          child: _buildGrid(context, apiController, funcController),
        )
        : _CardShell(
          onTap: () => _openDetail(),
          child: _buildList(context, apiController, funcController),
        );
  }

  void _openDetail() {
    // `Data` va `WishList` ikkalasi ham keladi — ikkinchisida kerakli
    // maydonlar allaqachon bor.
    final dataPost = post is Data ? post as Data : post;
    Get.to(() => PostDetailScreen(post: dataPost));
  }

  // ── Koʻrinishlar ──────────────────────────────────────────────────

  Widget _buildGrid(
    BuildContext context,
    ApiController apiController,
    FuncController funcController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: _mediaAspectRatio,
              child: _buildImage(context),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _buildActionBadge(context, apiController, funcController),
            ),
          ],
        ),
        // Katak balandligi [gridDelegate] da oʻlchangan — mazmun aynan
        // shu joyni egallaydi.
        Expanded(
          child: Padding(
            padding: _bodyPadding,
            child: _buildBody(context, funcController),
          ),
        ),
      ],
    );
  }

  /// Roʻyxat koʻrinishi.
  ///
  /// Avval chap tomonda butun balandlik boʻylab 128px surat ustuni bor
  /// edi: surat boʻlmasa, karta yarmi boʻsh kulrang maydon boʻlib qolardi.
  /// Endi surat — ixcham kvadrat, asosiy joyni esa eʼlonning oʻzi
  /// egallaydi: sarlavha, ish beruvchi, maosh, yorliqlar va tavsif.
  ///
  /// Balandlikni mazmun belgilaydi — `IntrinsicHeight` ham, cheksiz
  /// oʻlchamli surat ham yoʻq.
  Widget _buildList(
    BuildContext context,
    ApiController apiController,
    FuncController funcController,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(context),
              const SizedBox(width: 12),
              Expanded(child: _buildListHeading(context, funcController)),
              const SizedBox(width: 6),
              _buildActionBadge(
                context,
                apiController,
                funcController,
                subtle: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildListTags(context),
          const SizedBox(height: 10),
          Text(
            post.content ?? 'Tavsif yo‘q'.tr,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _descriptionStyle(theme)?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 1,
            color: colors.onSurface.withValues(alpha: 0.06),
          ),
          const SizedBox(height: 10),
          _buildListStats(context),
          if (mePost) ...[
            const SizedBox(height: _gapL),
            _buildEditButton(context),
          ],
        ],
      ),
    );
  }

  /// Roʻyxatdagi kvadrat surat. Surat boʻlmasa — brend rangida portfel.
  Widget _buildThumbnail(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    // Surat ekranda 76 dp; toʻliq oʻlchamda dekodlash ortiqcha xotira.
    final dpr = MediaQuery.devicePixelRatioOf(context);

    Widget placeholder() => ColoredBox(
      color: colors.primary.withValues(alpha: 0.08),
      child: Center(
        child: Icon(
          LucideIcons.briefcaseBusiness,
          size: 26,
          color: colors.primary.withValues(alpha: 0.7),
        ),
      ),
    );

    final url = post.pictureUrl as String?;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox.square(
        dimension: _thumbSize,
        child:
            url == null || url.isEmpty
                ? placeholder()
                : CachedNetworkImage(
                  imageUrl:
                      url.startsWith('http') ? url : 'https://ishtopchi.uz$url',
                  fit: BoxFit.cover,
                  width: _thumbSize,
                  height: _thumbSize,
                  memCacheWidth: (_thumbSize * dpr).round(),
                  fadeInDuration: const Duration(milliseconds: 220),
                  placeholder:
                      (context, _) => ColoredBox(
                        color: colors.onSurface.withValues(alpha: 0.06),
                      ),
                  errorWidget: (context, _, _) => placeholder(),
                ),
      ),
    );
  }

  /// Sarlavha, ish beruvchi va maosh.
  Widget _buildListHeading(
    BuildContext context,
    FuncController funcController,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = _muted(theme);
    final name =
        '${post.user?.firstName ?? ''} ${post.user?.lastName ?? ''}'.trim();
    // Avatar ekranda 18 dp — shu oʻlchamda dekodlanadi.
    final avatarSize = 18 * MediaQuery.devicePixelRatioOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          post.title ?? 'Noma’lum'.tr,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _titleStyle(theme, compact: false)?.copyWith(height: 1.25),
        ),
        if (name.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              CircleAvatar(
                radius: 9,
                backgroundColor: colors.onSurface.withValues(alpha: 0.08),
                // `CachedNetworkImageProvider` — rasm bir marta yuklanadi
                // va keshlanadi; `NetworkImage` kabi qayta soʻralmaydi.
                backgroundImage:
                    post.user?.profilePicture != null
                        ? CachedNetworkImageProvider(
                          funcController.getProfileUrl(
                            post.user?.profilePicture,
                          ),
                          maxWidth: avatarSize.round(),
                          maxHeight: avatarSize.round(),
                        )
                        : null,
                child:
                    post.user?.profilePicture == null
                        ? Icon(LucideIcons.user, size: 10, color: muted)
                        : null,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        // Maosh — eʼlonning eng muhim raqami: urgʻu rangida va oʻqish
        // oson boʻlishi uchun uchtalab guruhlangan.
        Text(
          '${_groupSalary(post.salaryFrom)} – ${_groupSalary(post.salaryTo)} UZS',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _salaryStyle(
            theme,
          )?.copyWith(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  /// Toifa, ish turi va tuman — ixcham yorliqlar.
  Widget _buildListTags(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _buildCategoryChip(context),
        if (post.jobType != null)
          _Tag(icon: LucideIcons.briefcase, text: _jobTypeLabel(post.jobType)),
        _Tag(
          icon: LucideIcons.mapPin,
          text: post.district?.name ?? 'Noma’lum'.tr,
        ),
      ],
    );
  }

  /// Qachon joylangani va necha marta koʻrilgani.
  Widget _buildListStats(BuildContext context) {
    final theme = Theme.of(context);
    final muted = _muted(theme);
    final style = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      color: muted,
    );

    Widget item(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: muted),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );

    // Ikkala qism ham moslashuvchan: oddiy holatda toʻliq koʻrinadi, juda
    // tor ekran yoki katta shriftda esa oxiridan qisqaradi — qator hech
    // qachon toshmaydi. Koʻrishlar soniga koʻproq joy beriladi.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: item(LucideIcons.clock, _relativeDate(post.createdAt)),
        ),
        Flexible(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: item(
              LucideIcons.eye,
              '${_groupDigits(post.views ?? 0)} ${'ko‘rish'.tr}',
            ),
          ),
        ),
      ],
    );
  }

  /// "Bugun", "Kecha", "3 kun oldin", "2 hafta oldin", undan keyin sana.
  ///
  /// Eʼlonning yangiligi aniq sanadan koʻra muhimroq — nisbiy
  /// koʻrinish bir qarashda tushuniladi.
  /// Sana matnlari keshi: `DateTime.tryParse` har bir karta uchun har
  /// qayta qurishda takrorlanmaydi.
  static final Map<String, DateTime?> _parsedDates = <String, DateTime?>{};

  static final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');

  static DateTime? _parseIso(String? iso) {
    if (iso == null) return null;
    if (_parsedDates.containsKey(iso)) return _parsedDates[iso];
    if (_parsedDates.length > 256) _parsedDates.clear();
    final parsed = DateTime.tryParse(iso);
    _parsedDates[iso] = parsed;
    return parsed;
  }

  static String _relativeDate(String? iso) {
    final parsed = _parseIso(iso);
    if (parsed == null) return 'Noma’lum'.tr;

    final date = parsed.toLocal();
    final now = DateTime.now();
    final days =
        DateTime(
          now.year,
          now.month,
          now.day,
        ).difference(DateTime(date.year, date.month, date.day)).inDays;

    if (days <= 0) return 'Bugun'.tr;
    if (days == 1) return 'Kecha'.tr;
    if (days < 7) return '$days ${'kun oldin'.tr}';
    if (days < 30) return '${days ~/ 7} ${'hafta oldin'.tr}';
    return _dateFormat.format(date);
  }

  /// "6000000" → "6 000 000". Raqam boʻlmasa — oʻzgarishsiz.
  static String _groupSalary(String? value) {
    if (value == null) return 'Noma’lum'.tr;
    final number = int.tryParse(value.trim());
    return number == null ? value : _groupDigits(number);
  }

  /// Raqamni uchtalab guruhlaydi: 12345 → 12 345.
  static String _groupDigits(int number) {
    final digits = number.abs().toString();
    final buffer = StringBuffer(number < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      // Uzilmas boʻshliq — raqam ikki qatorga boʻlinib ketmaydi.
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  // ── Qismlar ───────────────────────────────────────────────────────

  Widget _buildImage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholderColor = colors.onSurface.withValues(alpha: 0.06);

    Widget fallback() => Container(
      color: placeholderColor,
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.imageOff,
        size: 28,
        color: colors.onSurface.withValues(alpha: 0.3),
      ),
    );

    final url = post.pictureUrl;
    if (url == null || (url as String).isEmpty) return fallback();

    // Katakdagi surat kichik; `LayoutBuilder` haqiqiy kenglikni beradi va
    // surat shu oʻlchamda dekodlanadi (asl fayl emas).
    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final target = constraints.maxWidth * dpr;

        return CachedNetworkImage(
          imageUrl: url.startsWith('http') ? url : 'https://ishtopchi.uz$url',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: target.isFinite && target > 0 ? target.round() : null,
          fadeInDuration: const Duration(milliseconds: 220),
          placeholder: (context, _) => Container(color: placeholderColor),
          errorWidget: (context, _, _) => fallback(),
        );
      },
    );
  }

  /// Katakdagi mazmun.
  Widget _buildBody(BuildContext context, FuncController funcController) {
    // Katak balandligi oldindan oʻlchangan. Ortib qolgan joy mazmun
    // bilan muallif qatori orasiga tushadi — shunda bir qatordagi
    // kartalarning pastki qismi bir chiziqda turadi.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSummary(context, compact: true),
        _buildFooter(context, funcController),
      ],
    );
  }

  /// Sarlavha, toifa, tavsif, maosh va joylashuv.
  Widget _buildSummary(BuildContext context, {required bool compact}) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          post.title ?? 'Noma’lum'.tr,
          maxLines: compact ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: _titleStyle(theme, compact: compact),
        ),
        const SizedBox(height: _gapS),
        Row(
          children: [
            Flexible(child: _buildCategoryChip(context)),
            if (post.jobType != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _jobTypeLabel(post.jobType),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _jobTypeStyle(theme),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: _gapM),
        Text(
          post.content ?? 'Tavsif yo‘q'.tr,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: _descriptionStyle(theme),
        ),
        const SizedBox(height: _gapL),
        // Maosh — kartaning eng muhim raqami, shuning uchun urgʻu rangida.
        Text(
          '${post.salaryFrom ?? 'Noma’lum'.tr} - ${post.salaryTo ?? 'Noma’lum'.tr} UZS',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _salaryStyle(theme),
        ),
        const SizedBox(height: _gapS),
        _buildMetaRow(
          context,
          LucideIcons.mapPin,
          post.district?.name ?? 'Noma’lum'.tr,
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: _chipPadding,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        post.category?.title ?? 'Noma’lum'.tr,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _chipStyle(theme),
      ),
    );
  }

  Widget _buildMetaRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: _metaIconSize, color: _muted(theme)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _metaStyle(theme),
          ),
        ),
      ],
    );
  }

  /// Muallif va statistika — ikki qatorda.
  ///
  /// Ilgari ism, sana va koʻrishlar soni bitta qatorda edi. Tor katakda
  /// yoki katta shriftda ular sigʻmay, qator oʻngga toshib ketardi.
  Widget _buildFooter(BuildContext context, FuncController funcController) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = _muted(theme);

    final name =
        '${post.user?.firstName ?? ''} ${post.user?.lastName ?? ''}'.trim();
    final date = _relativeDate(post.createdAt);
    // Avatar ekranda 22 dp — shu oʻlchamda dekodlanadi.
    final avatarSize =
        _avatarRadius * 2 * MediaQuery.devicePixelRatioOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: colors.onSurface.withValues(alpha: 0.08),
              backgroundImage:
                  post.user?.profilePicture != null
                      ? CachedNetworkImageProvider(
                        funcController.getProfileUrl(post.user?.profilePicture),
                        maxWidth: avatarSize.round(),
                        maxHeight: avatarSize.round(),
                      )
                      : null,
              child:
                  post.user?.profilePicture == null
                      ? Icon(LucideIcons.user, size: 11, color: muted)
                      : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _authorNameStyle(theme),
              ),
            ),
          ],
        ),
        const SizedBox(height: _footerGap),
        // Sana va koʻrishlar bitta matnda: qatʼiy kenglikdagi qismlar
        // yoʻq, shuning uchun eng tor katakda ham toshmaydi — ortiqchasi
        // oxiridan qisqaradi.
        Text(
          '$date  ·  ${_groupDigits(post.views ?? 0)} ${'ko‘rish'.tr}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: _statStyle(theme),
        ),
        if (mePost) ...[
          const SizedBox(height: _gapL),
          _buildEditButton(context),
        ],
      ],
    );
  }

  Widget _buildEditButton(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      // Balandlik shrift bilan birga oʻsadi; katak hisobi ham aynan shu
      // qiymatni ishlatadi.
      height: _editButtonHeight(context),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: colors.primary.withValues(alpha: 0.12),
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          funcController.setBarIndex(1);
        },
        child: Text('Tahrirlash'.tr, style: _editLabelStyle),
      ),
    );
  }

  /// Surat ustidagi dumaloq tugma: oʻchirish (oʻz eʼloni) yoki
  /// saralanganlarga qoʻshish.
  Widget _buildActionBadge(
    BuildContext context,
    ApiController apiController,
    FuncController funcController, {
    bool subtle = false,
  }) {
    if (mePost) {
      return _BadgeButton(
        subtle: subtle,
        icon: Icons.delete_outline_rounded,
        color: Theme.of(context).colorScheme.error,
        onPressed: () async {
          //await apiController.deletePost(post.id!.toInt());
        },
      );
    }

    return Obx(() {
      final isFavorite = funcController.wishList.any((w) => w.id == post.id);
      final colors = Theme.of(context).colorScheme;

      return _BadgeButton(
        subtle: subtle,
        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
        color:
            isFavorite
                ? colors.error
                : subtle
                ? colors.onSurface.withValues(alpha: 0.55)
                : colors.onSurface,
        // Bosilganda belgi yengil "urib" qoʻyadi — holat oʻzgargani
        // darhol seziladi.
        bump: isFavorite,
        onPressed: () async {
          if (isFavorite) {
            await apiController.removeFromWishlist(post.id!.toInt());
          } else {
            await apiController.addToWishlist(post.id!.toInt());
          }
        },
      );
    });
  }

  FuncController get funcController => Get.find<FuncController>();

  String _jobTypeLabel(String? type) {
    switch (type) {
      case 'FULL_TIME':
        return 'To‘liq ish kuni'.tr;
      case 'TEMPORARY':
        return 'Vaqtinchalik ish'.tr;
      case 'REMOTE':
        return 'Masofaviy ish'.tr;
      case 'DAILY':
        return 'Kunlik ish'.tr;
      case 'PROJECT_BASED':
        return 'Loyihaviy ish'.tr;
      case 'INTERNSHIP':
        return 'Amaliyot'.tr;
      default:
        return 'Noma’lum'.tr;
    }
  }
}

/// Kartaning tashqi qobigʻi: fon, radius, kontur va bosish javobi.
class _CardShell extends StatefulWidget {
  const _CardShell({required this.child, required this.onTap});

  /// Karta atrofidagi boʻshliq va kontur qalinligi — katak balandligi
  /// hisobi ham shularni ishlatadi.
  static const EdgeInsets inset = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 6,
  );
  static const double borderWidth = 1;

  final Widget child;
  final VoidCallback onTap;

  @override
  State<_CardShell> createState() => _CardShellState();
}

class _CardShellState extends State<_CardShell> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final radius = BorderRadius.circular(AppTheme.radiusCard);

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Container(
        margin: _CardShell.inset,
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? colors.surfaceContainer,
          borderRadius: radius,
          // Soya oʻrniga nozik kontur — qorongʻi fonda soya koʻrinmaydi.
          border: Border.all(
            color: colors.onSurface.withValues(alpha: 0.08),
            width: _CardShell.borderWidth,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            splashColor: colors.onSurface.withValues(alpha: 0.05),
            highlightColor: colors.onSurface.withValues(alpha: 0.03),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Surat ustidagi dumaloq tugma.
class _BadgeButton extends StatelessWidget {
  const _BadgeButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.bump = false,
    this.subtle = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  /// Belgi faol holatga oʻtganda yengil kattalashadi.
  final bool bump;

  /// Surat ustida emas, karta fonida turadi — fon deyarli sezilmaydi.
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color:
          subtle
              ? colors.onSurface.withValues(alpha: 0.05)
              : colors.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: AnimatedScale(
            scale: bump ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}

/// Roʻyxatdagi ixcham yorliq: belgi va matn. Matn uzun boʻlsa
/// qisqaradi — yorliq hech qachon qatordan chiqib ketmaydi.
class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurface.withValues(alpha: 0.65);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: muted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
