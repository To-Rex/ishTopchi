import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Qurilma ogʻir grafik effektlarni koʻtara oladimi.
///
/// Xiralash (`BackdropFilter`) har bir kadrda orqa fonni qayta chizadi.
/// Zamonaviy telefonlarda bu sezilmaydi, lekin eski yoki kuchsiz
/// qurilmalarda aylantirish paytida kadrlar tushib, ilova "qotib"
/// qolishi mumkin. Shunday qurilmalarda xiralash oʻrniga oddiy, deyarli
/// bepul rang ishlatiladi.
///
/// Qiymat ilova ochilishida bir marta aniqlanadi ([init]) va keyin
/// sinxron oʻqiladi.
class DeviceCapabilities {
  const DeviceCapabilities._();

  static bool _reduceEffects = false;

  /// `true` boʻlsa — xiralash kabi ogʻir effektlar ishlatilmaydi.
  static bool get reduceEffects => _reduceEffects;

  /// Testlar uchun.
  @visibleForTesting
  static set debugReduceEffects(bool value) => _reduceEffects = value;

  /// Android 10 dan eski qurilmalarda Flutter yangi grafik dvigatelni
  /// (Impeller) ishlatmaydi va xiralash ancha qimmat.
  static const int _minSdkForEffects = 29;

  /// Shundan kam operativ xotirali qurilmalar kuchsiz hisoblanadi.
  /// "3 GB" telefonlar tizimga taxminan 2.7–2.9 GB deb koʻrinadi,
  /// "4 GB" lilar esa 3.6 GB dan yuqori.
  static const int _minRamMb = 3500;

  /// Ilova ochilishida bir marta chaqiriladi.
  ///
  /// Aniqlab boʻlmasa (xato, boshqa platforma) — toʻliq effektlar qoladi.
  static Future<void> init() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final info = await DeviceInfoPlugin().androidInfo;
      final ram = info.physicalRamSize;
      _reduceEffects =
          info.version.sdkInt < _minSdkForEffects ||
          info.isLowRamDevice ||
          (ram > 0 && ram < _minRamMb);
    } catch (_) {
      _reduceEffects = false;
    }
  }
}
