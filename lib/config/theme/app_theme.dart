import 'package:flutter/material.dart';
import 'app_brand.dart';
import 'app_colors.dart';

/// Ilovaning mavzulari.
///
/// Dizayn qoidalari — butun ilova uchun:
/// * gradiyent yoʻq, faqat tekis rang;
/// * soya deyarli yoʻq — chuqurlik yuza rangining pogʻonalari bilan
///   beriladi (fon → karta), chunki navy fonda soya koʻrinmaydi;
/// * bitta radius shkalasi: 16 (tugma, maydon), 18 (karta), 28 (varaq);
/// * matnda soya yoʻq va yirik oʻlchamlarda interval manfiy.
///
/// Komponent mavzulari ataylab shu yerda belgilangan: shunda ekranlar
/// oʻz uslubini qoʻlda yozmasdan yangi koʻrinishga oʻtadi.
class AppTheme {
  const AppTheme._();

  // Radius shkalasi.
  static const double radiusControl = 16;
  static const double radiusCard = 18;
  static const double radiusSheet = 28;

  /// Eski kod bilan moslik — `theme` qorongʻi mavzuga ishora qiladi.
  static ThemeData get theme => darkTheme;

  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Sxema brend urugʻidan (logotip navy'si) hosil qilinadi, soʻng
    // [AppColors] qiymatlari bilan aniq moslashtiriladi — shunda
    // `Theme.of(context).colorScheme` va `AppColors` bir xil ranglarni
    // beradi, ikki manba orasida farq qolmaydi.
    final base = AppBrand.scheme(brightness);
    final colors = base.copyWith(
      surface: isDark ? AppColors.darkNavy : AppColors.lightBackground,
      onSurface: isDark ? AppColors.lightGray : AppColors.lightText,
      surfaceContainer: isDark ? AppColors.darkBlue : AppColors.lightSurface,
      surfaceContainerHighest:
          isDark ? AppColors.darkBlue : AppColors.lightSurface,
      primary: isDark ? AppColors.midBlue : AppColors.lightPrimary,
      onPrimary: isDark ? AppColors.white : AppColors.white,
      secondary: isDark ? AppColors.lightBlue : AppColors.lightSecondary,
      outline: isDark ? AppColors.lightBlue : AppColors.lightSecondary,
      outlineVariant: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      error: AppColors.red,
    );

    final onSurface = colors.onSurface;
    final muted = isDark ? AppColors.lightBlue : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkBlue : AppColors.lightCard;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;

    // Qorongʻi mavzuda yuzalar orasidagi farq kichik, shuning uchun
    // kartalar yupqa kontur bilan ajratiladi. Yorugʻ mavzuda karta oq
    // fonda oʻzi koʻrinadi — u yerda kontur yengilroq.
    final cardBorder =
        isDark
            ? AppColors.white.withValues(alpha: 0.07)
            : AppColors.lightDivider;

    return ThemeData(
      useMaterial3: true,
      // Avvalgi mavzuda `brightness` umuman belgilanmagan edi, shuning
      // uchun qorongʻi mavzu ham Flutter uchun "yorugʻ" hisoblanardi va
      // barcha standart ranglar notoʻgʻri chiqardi.
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      // InkSparkle oʻrniga: yumshoqroq tarqaladi va maxsus splash
      // ranglarini hisobga oladi.
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: _textTheme(onSurface, muted),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface, size: 22),
        actionsIconTheme: IconThemeData(color: onSurface, size: 22),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: onSurface,
        ),
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: cardBorder, width: 1),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.38),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: 0.7),
          // Soya yoʻq: chuqurlik rang kontrasti bilan beriladi.
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusControl),
          ),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          side: BorderSide(
            color: onSurface.withValues(alpha: 0.22),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusControl),
          ),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: _inputTheme(colors, brightness),

      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: muted.withValues(alpha: 0.4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusSheet),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        contentTextStyle: TextStyle(fontSize: 14.5, height: 1.45, color: muted),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkBlue : AppColors.lightText,
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: isDark ? AppColors.lightGray : AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: colors.primary,
        side: BorderSide(color: divider, width: 1),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: colors.primary,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
        linearMinHeight: 2,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: muted,
        textColor: onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      iconTheme: IconThemeData(color: onSurface, size: 22),
    );
  }

  /// Matn shkalasi.
  ///
  /// Soya yoʻq (avvalgi mavzuda `headlineLarge` da soya bor edi) va yirik
  /// oʻlchamlarda interval manfiy — yirik matn shunda yigʻilib turadi.
  static TextTheme _textTheme(Color onSurface, Color muted) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 36,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: onSurface,
      ),
      headlineLarge: TextStyle(
        fontSize: 30,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 25,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 21,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: muted,
      ),
      labelSmall: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: muted,
      ),
    );
  }

  /// Matn maydonlari — login oqimidagi maydonlar bilan bir xil uslub.
  static InputDecorationTheme _inputTheme(
    ColorScheme colors,
    Brightness brightness,
  ) {
    final field = AppBrand.fieldColors(colors, brightness);
    final radius = BorderRadius.circular(radiusControl);

    OutlineInputBorder borderWith(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      filled: true,
      fillColor: field.fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      hintStyle: TextStyle(fontSize: 15, color: field.hint),
      labelStyle: TextStyle(fontSize: 15, color: field.hint),
      border: borderWith(field.border, 1.2),
      enabledBorder: borderWith(field.border, 1.2),
      focusedBorder: borderWith(field.focus, 1.6),
      errorBorder: borderWith(colors.error, 1.2),
      focusedErrorBorder: borderWith(colors.error, 1.6),
      errorStyle: TextStyle(fontSize: 12.5, height: 1.3, color: colors.error),
    );
  }
}
