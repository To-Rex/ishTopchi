# Ishtopchi - Ish Topish va E‘lon Joylash Ilovasi

## Loyiha haqida

**Ishtopchi** - Flutter asosida ishlab chiqilgan mobil ilova bo‘lib, ish beruvchilar va ish qidiruvchilar uchun mo‘ljallangan. Ish beruvchilar vakansiya e‘lonlarini joylashtirishi, ish qidiruvchilar esa mos keladigan ishlarni qidirish, filtrlar orqali natijalarni toraytirish va yoqtirgan e‘lonlarni saqlash imkoniyatiga ega. Ilovaga Google Account yoki Telegram OTP orqali kirish mumkin. Ilova zamonaviy, foydalanuvchilarga qulay interfeys orqali ish topish va e‘lon joylash jarayonini soddalashtiradi.

## Asosiy funksiyalar

Ilova quyidagi funksiyalarni taqdim etadi:

- **Ish e‘lonlari joylash**:
  - Ish beruvchilar vakansiya e‘lonlarini yaratishi, tavsif, maosh, joylashuv va boshqa detallarni kiritishi mumkin.
  - Rasm yuklash (`image_picker`) va joylashuvni xaritada belgilash (`flutter_map`, `geolocator`).
- **Qidiruv va filtrlar**:
  - E‘lonlarni viloyat, tuman, ish turi, bandlik turi (To‘liq kunlik, Vaqtincha, Masofaviy, Kunlik ish, Loyihaviy asosda, Amaliyot) va narx oralig‘i bo‘yicha filtrlash.
  - Kalit so‘zlar orqali qidiruv (`http`, `dio`).
- **Yoqtirganlar ro‘yxati**:
  - Foydalanuvchilar yoqtirgan e‘lonlarni saqlab qo‘yishi mumkin (`get_storage`).
- **Autentifikatsiya**:
  - Google Account orqali kirish (`google_sign_in`, `firebase_auth`).
  - Telefon raqami orqali Telegram OTP tasdiqlash (`mask_text_input_formatter`, `pin_code_fields`).
- **Interaktiv UI**:
  - Moslashuvchan dizayn (`flutter_screenutil`).
  - Animatsiyali kartochkalar (`flutter_staggered_animations`).
  - Yuklashda skeleton effekti (`shimmer`) va pull-to-refresh (`pull_to_refresh_flutter3`).
- **Xarita integratsiyasi**:
  - Ish joylashuvini xaritada ko‘rsatish (`flutter_map`, `latlong2`).
  - Geolokatsiya xizmatlari (`geolocator`, `permission_handler`).
- **Keshlangan rasmlar**:
  - E‘lon rasmlarini tezkor yuklash uchun keshlash (`cached_network_image`).
- **Kirish sahifasi**:
  - Foydalanuvchilarni ilova bilan tanishtirish uchun interaktiv sahifa (`introduction_screen`).

## Texnologiyalar

Ilova quyidagi kutubxonalar va texnologiyalardan foydalanadi (`pubspec.yaml` asosida):

- **Framework**: Flutter (Dart, SDK ^3.7.2)
- **State boshqaruvi**: `get` (^4.7.2) - Reaktiv holat boshqaruvi.
- **Ma‘lumotlar saqlash**: `get_storage` (^2.1.1) - Mahalliy saqlash.
- **Autentifikatsiya**:
  - `google_sign_in` (^6.3.0) - Google orqali kirish.
  - `firebase_auth` (^5.5.3) - Firebase autentifikatsiyasi.
  - `firebase_core` (^3.13.0) - Firebase integratsiyasi.
  - `mask_text_input_formatter` (^2.9.0) va `pin_code_fields` (^8.0.1) - Telefon raqami va OTP kiritish.
- **API va tarmoq**:
  - `dio` (^5.8.0+1) va `http` (^1.4.0) - REST API so‘rovlari.
- **UI va dizayn**:
  - `flutter_screenutil` (^5.9.3) - Moslashuvchan UI.
  - `lucide_icons_flutter` (^3.0.0) va `icons_plus` (^5.0.0) - Ikonkalar.
  - `dropdown_button2` (^2.3.9) - Kengaytirilgan dropdown menyular.
  - `shimmer` (^3.0.0) - Skeleton loading effekti.
  - `flutter_staggered_animations` (^1.1.1) - Animatsiyali ro‘yxatlar.
  - `pull_to_refresh_flutter3` (^2.0.2) - Yuklash/yangilash funksiyasi.
  - `introduction_screen` (^3.1.14) - Kirish sahifasi.
  - `sign_in_button` (^3.2.0) - Kirish tugmalari.
- **Xarita va geolokatsiya**:
  - `flutter_map` (^8.1.1) va `flutter_map_animations` (^0.9.0) - Xarita ko‘rsatish.
  - `latlong2` (^0.9.1) - Joylashuv kordinatalari.
  - `geolocator` (^14.0.2) va `permission_handler` (^12.0.1) - Geolokatsiya va ruxsatlar.
- **Rasmlar va fayllar**:
  - `image_picker` (^1.1.2) - Rasm tanlash.
  - `cached_network_image` (^3.4.1) - Keshlangan tarmoq rasmlari.
  - `path_provider` (^2.1.5) - Fayl tizimi bilan ishlash.
- **Boshqa**: `url_launcher` (^6.3.1) - Tashqi havolalarni ochish.

## O‘rnatish

### Talablar
- Flutter SDK: >=3.7.2
- Dart: >=2.17.0
- Android Studio yoki VS Code
- Internet aloqasi (API so‘rovlari uchun)
- Firebase loyihasi (Google Sign-In va Firebase Auth uchun)
- Telegram Bot API (OTP tasdiqlash uchun)

### O‘rnatish qadamlari
1. **Repozitoriyani klonlash**:
   ```bash
   git clone https://github.com/To-Rex/ishTopchi.git
   cd ishTopchi
   ```

2. **Bog‘liqliklarni o‘rnatish**:
   `pubspec.yaml` faylida quyidagi kutubxonalar mavjud:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     cupertino_icons: ^1.0.8
     google_sign_in: ^6.3.0
     sign_in_button: ^3.2.0
     introduction_screen: ^3.1.14
     get: ^4.7.2
     get_storage: ^2.1.1
     firebase_core: ^3.13.0
     lucide_icons_flutter: ^3.0.0
     icons_plus: ^5.0.0
     dio: ^5.8.0+1
     firebase_auth: ^5.5.3
     url_launcher: ^6.3.1
     mask_text_input_formatter: ^2.9.0
     pin_code_fields: ^8.0.1
     dropdown_button2: ^2.3.9
     image_picker: ^1.1.2
     path_provider: ^2.1.5
     http: ^1.4.0
     flutter_map: ^8.1.1
     flutter_map_animations: ^0.9.0
     latlong2: ^0.9.1
     geolocator: ^14.0.2
     permission_handler: ^12.0.1
     cached_network_image: ^3.4.1
     flutter_staggered_animations: ^1.1.1
     pull_to_refresh_flutter3: ^2.0.2
     flutter_screenutil: ^5.9.3
     shimmer: ^3.0.0
   ```
   Bog‘liqliklarni o‘rnatish:
   ```bash
   flutter pub get
   ```

3. **Sozlamalar**:
   - **Firebase sozlamalari**:
     - Firebase loyihasi yarating va `google-services.json` (Android) va `GoogleService-Info.plist` (iOS) fayllarini `android/app` va `ios/Runner` jildlariga qo‘shing.
     - `main.dart`da Firebase’ni ishga tushiring:
       ```dart
       void main() async {
         WidgetsFlutterBinding.ensureInitialized();
         await Firebase.initializeApp();
         ScreenUtil.init(
           BoxConstraints(maxWidth: 414, maxHeight: 896),
           designSize: Size(414, 896),
         );
         runApp(MyApp());
       }
       ```
   - **Telegram OTP**:
     - Telegram Bot API tokenini va OTP tasdiqlash endpointini `ApiController`da sozlang (masalan, `/auth/otp`).
     - Telefon raqami formati `+998` bilan boshlanishini ta’minlang.
   - **Xarita**:
     - `flutter_map` uchun xarita provayderi (masalan, OpenStreetMap) API kalitini sozlang.
   - **Ruxsatlar**:
     - Android uchun `AndroidManifest.xml`:
       ```xml
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
       <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
       ```
     - iOS uchun `Info.plist`:
       ```xml
       <key>NSLocationWhenInUseUsageDescription</key>
       <string>Ish joylashuvini aniqlash uchun ruxsat kerak</string>
       <key>NSPhotoLibraryUsageDescription</key>
       <string>E‘lon uchun rasm tanlash</string>
       <key>NSCameraUsageDescription</key>
       <string>E‘lon uchun rasm olish</string>
       ```

4. **Ilovani ishga tushirish**:
   ```bash
   flutter run
   ```

## Foydalanish bo‘yicha ko‘rsatmalar

1. **Kirish**:
   - **Google Account**: `sign_in_button` orqali Google bilan kirish.
   - **Telegram OTP**: Telefon raqamini kiritish (`mask_text_input_formatter`) va OTP kodini tasdiqlash (`pin_code_fields`).
   - Kirish ma‘lumotlari `get_storage`da saqlanadi.

2. **E‘lonlarni ko‘rish**:
   - Asosiy ekranda e‘lonlar grid shaklida ko‘rinadi (`flutter_staggered_animations`).
   - Qidiruv maydoni orqali kalit so‘zlar bo‘yicha qidirish (`http`, `dio`).
   - Yuklanayotganda skeleton effekti (`shimmer`) va pull-to-refresh (`pull_to_refresh_flutter3`).

3. **Filtrlash**:
   - Filtr dialogida (`dropdown_button2`):
     - **Viloyat** va **Shahar/Tuman**: API orqali dinamik yuklanadi.
     - **Narx oralig‘i**: `min_price` va `max_price` kiritish.
     - **Ish turi**: Kategoriyalar (masalan, IT, Marketing).
     - **Bandlik turi**: To‘liq kunlik, Vaqtincha, Masofaviy, Kunlik ish, Loyihaviy asosda, Amaliyot.
   - “Qo‘llash” tugmasi filtrlangan e‘lonlarni yuklaydi, “Tozalash” filtrlarni olib tashlaydi.

4. **Yoqtirganlar ro‘yxati**:
   - E‘lon kartochkasidagi “Yoqtirish” tugmasi orqali saqlash (`get_storage`).
   - Saqlangan e‘lonlar maxsus bo‘limda ko‘rinadi.

5. **E‘lon joylash**:
   - Ish beruvchilar e‘lon yaratishda rasm (`image_picker`), joylashuv (`flutter_map`, `geolocator`) va boshqa detallarni kiritadi.
   - Ma‘lumotlar API orqali serverga yuboriladi (`dio`).

6. **Xarita va geolokatsiya**:
   - Ish joylashuvi xaritada ko‘rsatiladi (`flutter_map`, `flutter_map_animations`).
   - Foydalanuvchi joylashuvi `geolocator` orqali aniqlanadi.

7. **Kirish sahifasi**:
   - Yangi foydalanuvchilar uchun interaktiv kirish sahifasi (`introduction_screen`).

## Loyiha tuzilishi

```
ishTopchi/
├── lib/
│   ├── common/
│   │   └── widgets/
│   │       └── refresh_component.dart
│   ├── config/
│   │   └── theme/
│   │       ├── app_colors.dart
│   │       └── app_dimensions.dart
│   ├── controllers/
│   │   ├── api_controller.dart
│   │   └── funcController.dart
│   ├── core/
│   │   ├── models/
│   │   │   ├── post_model.dart
│   │   │   ├── user_me.dart
│   │   │   └── wish_list.dart
│   │   └── utils/
│   │       └── responsive.dart
│   ├── modules/
│   │   └── main/
│   │       ├── views/
│   │       │   ├── main_content.dart
│   │       │   ├── show_filter_dialog.dart
│   │       │   └── skeleton_post_card.dart
│   │       └── widgets/
│   │           └── post_card.dart
├── assets/
├── pubspec.yaml
└── README.md
```

## Muammolarni bartaraf qilish

- **API ulanmadi**: `ApiController`da server URL va endpointlarini tekshiring (masalan, `https://api.ishtopchi.uz`).
- **Google Sign-In xatosi**:
  - `google-services.json` va `GoogleService-Info.plist` fayllari to‘g‘ri joylashtirilganligini tekshiring.
  - Android uchun SHA-1 kalitini Firebase konsolida qo‘shing.
- **Telegram OTP ishlamayapti**:
  - Telefon raqami formati (`+998901234567`) va server tasdiqlash endpointini tekshiring.
- **Xarita ko‘rinmayapti**:
  - `flutter_map` uchun API kaliti (masalan, OpenStreetMap) sozlanganligiga ishonch hosil qiling.
  - `permission_handler` orqali joylashuv ruxsatlari so‘ralganligini tekshiring.
- **UI noto‘g‘ri ko‘rinishda**:
  - `flutter_screenutil` sozlamalarini tekshiring va `ScreenUtil.init` `main.dart`da chaqirilganligiga ishonch hosil qiling:
    ```dart
    ScreenUtil.init(
      BoxConstraints(maxWidth: 414, maxHeight: 896),
      designSize: Size(414, 896),
    );
    ```

## Hissalar

Loyihaga hissa qo‘shmoqchi bo‘lsangiz:
1. Repozitoriyani fork qiling: [https://github.com/To-Rex/ishTopchi](https://github.com/To-Rex/ishTopchi).
2. Yangi branch yarating (`git checkout -b feature/your-feature`).
3. O‘zgarishlarni kiriting va commit qiling (`git commit -m "Yangi funksiya qo‘shildi"`).
4. Push qiling (`git push origin feature/your-feature`).
5. Pull Request oching.

## Litsenziya

Bu loyiha MIT Litsenziyasi ostida tarqatiladi. Batafsil ma‘lumot uchun `LICENSE` faylini ko‘ring.

## Aloqa

Savollar yoki takliflar uchun:
- Email: support@ishtopchi.uz
- Telegram: @IshtopchiSupport