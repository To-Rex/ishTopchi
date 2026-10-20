import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Brend rang tizimi.
///
/// Yorugʻ mavzu logotipdan olingan navy'ga (#0A2A66) tayanadi. Qorongʻi
/// mavzu esa neytral qora shkalada quriladi ([AppColors] dagi qiymatlar
/// bilan bir xil), koʻk esa faqat urgʻu boʻlib qoladi.
///
/// Kirish maydonining ranglari — [AppBrand.fieldColors] qaytaradi.
class BrandFieldColors {
  const BrandFieldColors({
    required this.fill,
    required this.border,
    required this.focus,
    required this.hint,
  });

  /// Maydon ichidagi toʻldirish.
  final Color fill;

  /// Tinch holatdagi kontur.
  final Color border;

  /// Fokusdagi kontur.
  final Color focus;

  /// Boʻsh maydondagi namuna matn.
  final Color hint;
}

class AppBrand {
  const AppBrand._();

  /// Logotip navy'si. Yorugʻ mavzu shu urugʻdan hosil qilinadi.
  static const Color seed = Color(0xFF0A2A66);

  /// Logotipdagi oq.
  static const Color ink = Color(0xFFFFFFFF);

  /// Qorongʻi rejim foni — neytral, qoraga yaqin.
  ///
  /// Ilgari bu yerda navy (`#071E4A`) turardi. Koʻk fon tungi rejimda
  /// ogʻir koʻrinadi va ekranni "moviy" qilib qoʻyadi; neytral qora esa
  /// kontentni oldinga chiqaradi va brend koʻkini urgʻu sifatida
  /// saqlaydi.
  static const Color _darkSurface = AppColors.darkNavy;

  /// Qorongʻi rejimdagi urgʻu — brend koʻkining yorugʻroq varianti.
  static const Color _darkPrimary = AppColors.midBlue;

  /// Qorongʻi rejimdagi asosiy matn.
  static const Color _darkOnSurface = AppColors.lightGray;

  /// Yorugʻ rejim foni — sovuq oq, navy bilan bir oilada.
  static const Color _lightSurface = Color(0xFFF6F7FB);

  /// Material 3 sxemasi. Yuzalar va asosiy rang qoʻlda belgilanadi,
  /// qolgan 25+ rolni Material oʻzi kontrastni kafolatlagan holda hisoblaydi.
  static ColorScheme scheme(Brightness brightness) {
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    if (brightness == Brightness.dark) {
      return base.copyWith(
        primary: _darkPrimary,
        // Koʻk tugma ustida oq matn — kontrast 4.6:1.
        onPrimary: ink,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
      );
    }

    return base.copyWith(
      primary: seed,
      onPrimary: ink,
      surface: _lightSurface,
      onSurface: seed,
    );
  }

  /// Kirish maydonlarining ranglari.
  ///
  /// Qorongʻi rejimda qiymatlar aniq beriladi, shaffoflik orqali emas.
  /// Bu ataylab: foydalanuvchi maydon konturi tungi mavzuda koʻrinmay
  /// qolganini aytgan edi, shuning uchun kontur fon bilan 3:1 kontrast
  /// beradigan darajada yorugʻ.
  static BrandFieldColors fieldColors(
    ColorScheme colors,
    Brightness brightness,
  ) {
    if (brightness == Brightness.dark) {
      return const BrandFieldColors(
        // Fondan bir pogʻona yorugʻroq — maydon "chuqurcha" boʻlib koʻrinadi.
        fill: Color(0xFF141417),
        border: AppColors.darkBorder,
        // Fokusda kontur brend koʻkiga oʻtadi — qaysi maydon faol
        // ekani rangdan darhol bilinadi.
        focus: Color(0xFF6E9BFF),
        hint: Color(0xFF85858E),
      );
    }

    return BrandFieldColors(
      fill: colors.onSurface.withValues(alpha: 0.05),
      border: colors.onSurface.withValues(alpha: 0.38),
      focus: colors.primary,
      hint: colors.onSurface.withValues(alpha: 0.42),
    );
  }

  /// Login ekrani uchun mahalliy mavzu.
  ///
  /// Ataylab yangi [ThemeData] quriladi, `Theme.of(context).copyWith(...)`
  /// emas: eski `AppTheme` matn uslublarida soya (`shadows`) bor, u yangi
  /// dizaynga tushmaydi.
  static ThemeData themeFor(Brightness brightness) {
    final colors = scheme(brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      // InkSparkle emas: uning uchquni qattiq koʻrinadi va maxsus
      // splashColor'ni hisobga olmaydi. InkRipple yumshoqroq tarqaladi.
      splashFactory: InkRipple.splashFactory,
    );
  }
}
