import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/theme_controller.dart';

/// Ilovaning rang palitrasi.
///
/// Yorugʻ mavzu `assets/logo.png` dagi brend navy'si (`#0A2A66`) atrofida
/// qurilgan. Qorongʻi mavzu esa **neytral**: fon va yuzalar qoraga yaqin
/// kulranglar, koʻk faqat urgʻu sifatida qoladi. Koʻk fon qorongʻi
/// rejimda ogʻir koʻrinardi va tungi foydalanishga notoʻgʻri edi.
///
/// Klassning API'si ataylab oʻzgartirilmagan: nomlar ham, mavzuga bogʻliq
/// getterlar ham avvalgidek. Ekranlar shu nomlarga 900+ joyda murojaat
/// qiladi, shuning uchun faqat qiymatlar yangilandi — bitta ekran ham
/// buzilmaydi, lekin hammasi bir vaqtda yangi palitraga oʻtadi.
///
/// Konstantalar `const` boʻlib qoladi: ular ayrim joylarda `const`
/// ifodalar ichida ishlatiladi.
class AppColors {
  // ── Qorongʻi mavzu ────────────────────────────────────────────────
  // Neytral qora shkala. Koʻk tus yoʻq — shuning uchun OLED ekranda
  // chuqur koʻrinadi va brend koʻki urgʻu boʻlib ajralib turadi.
  //
  // Nomlar tarixiy (`darkNavy`, `midBlue`): ular 900+ joyda ishlatiladi,
  // shuning uchun faqat qiymatlar oʻzgardi.
  /// Asosiy fon — qoraga yaqin, lekin sof qora emas: sof qorada
  /// yuzalarning pogʻonasi koʻrinmay qoladi.
  static const Color darkNavy = Color(0xFF0B0B0D);

  /// Yuza: kartalar, panellar, varaqlar. Fondan bir pogʻona yorugʻroq.
  static const Color darkBlue = Color(0xFF151517);

  /// Urgʻu rangi — brend koʻkining yorugʻroq varianti.
  ///
  /// Logotip navy'sining oʻzi (`#0A2A66`) qora fonda deyarli koʻrinmaydi.
  /// Bu ton esa oq matnni koʻtaradi (4.6:1) va qora fonda ham ajralib
  /// turadi (4.3:1) — tugma foni va urgʻu matni uchun bir vaqtda.
  static const Color midBlue = Color(0xFF3D6FE0);

  /// Ikkilamchi matn va ikonkalar — neytral kulrang.
  static const Color lightBlue = Color(0xFF9A9AA3);

  /// Asosiy matn — sof oq emas, juda yengil kulrang: qora fonda sof oq
  /// matn "yonib" koʻrinadi.
  static const Color lightGray = Color(0xFFF1F1F3);

  /// Qorongʻi mavzudagi ajratkich — oq, past shaffoflikda.
  static const Color darkDivider = Color(0x1FFFFFFF);

  /// Qorongʻi mavzudagi kontur (kartalar, maydonlar chegarasi).
  static const Color darkBorder = Color(0xFF5E5E67);

  /// Qorongʻi mavzudagi soya — endi neytral qora, koʻk tussiz.
  static const Color darkShadow = Color(0x59000000);

  static const Color white = Color(0xFFFFFFFF);

  // ── Yorugʻ mavzu ──────────────────────────────────────────────────
  /// Asosiy fon — sovuq oq, navy bilan bir oilada.
  static const Color lightBackground = Color(0xFFF5F7FC);

  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Urgʻu rangi — logotip navy'sining oʻzi.
  static const Color lightPrimary = Color(0xFF0A2A66);

  static const Color lightSecondary = Color(0xFF5F7098);

  /// Asosiy matn — sof qora emas, juda toʻq navy.
  static const Color lightText = Color(0xFF0C1B38);

  static const Color lightTextSecondary = Color(0xFF5F7098);

  static const Color lightDivider = Color(0xFFE3E8F2);

  static const Color lightCard = Color(0xFFFFFFFF);

  /// Soya — neytral qora emas, navy tusli. Shuning uchun u fon bilan
  /// bir oilada qoladi va "kir" koʻrinmaydi.
  static const Color lightShadow = Color(0x140A2A66);

  // ── Semantik ranglar ──────────────────────────────────────────────
  // Faqat maʼno uchun: xato, ogohlantirish, muvaffaqiyat. Bezak sifatida
  // ishlatilmaydi, aks holda palitra tarqab ketadi.
  static const Color red = Color(0xFFE5484D);
  static const Color selectedItem = Color(0xFFE5484D); // Tanlangan uchun
  static const Color yellow = Color(0xFFF5A524);
  static const Color green = Color(0xFF2FA36B);

  // ── Mavzuga bogʻliq ranglar ───────────────────────────────────────
  // Joriy mavzuga qarab avtomatik almashadi.
  static Color get backgroundColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? darkNavy : lightBackground;
    } catch (e) {
      return darkNavy; // Default to dark if controller not found
    }
  }

  static Color get surfaceColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? darkBlue : lightSurface;
    } catch (e) {
      return darkBlue; // Default to dark if controller not found
    }
  }

  static Color get primaryColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? midBlue : lightPrimary;
    } catch (e) {
      return midBlue; // Default to dark if controller not found
    }
  }

  static Color get secondaryColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? lightBlue : lightSecondary;
    } catch (e) {
      return lightBlue; // Default to dark if controller not found
    }
  }

  static Color get textColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? lightGray : lightText;
    } catch (e) {
      return lightGray; // Default to dark if controller not found
    }
  }

  static Color get textSecondaryColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? lightBlue : lightTextSecondary;
    } catch (e) {
      return lightBlue; // Default to dark if controller not found
    }
  }

  static Color get cardColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? darkBlue : lightCard;
    } catch (e) {
      return darkBlue; // Default to dark if controller not found
    }
  }

  static Color get dividerColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? darkDivider : lightDivider;
    } catch (e) {
      return darkDivider;
    }
  }

  static Color get shadowColor {
    try {
      final controller = Get.find<ThemeController>();
      // Qorongʻi mavzuda soya koʻrinmaydi — uning oʻrniga yuza rangi
      // bilan chuqurlik beriladi, shuning uchun soya juda yengil.
      return controller.isDarkMode.value ? darkShadow : lightShadow;
    } catch (e) {
      return darkShadow;
    }
  }

  static Color get iconColor {
    try {
      final controller = Get.find<ThemeController>();
      return controller.isDarkMode.value ? lightBlue : lightPrimary;
    } catch (e) {
      return lightBlue; // Default to dark if controller not found
    }
  }
}
