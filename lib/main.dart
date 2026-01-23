import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ishtopchi/modules/messages/controllers/messages_controller.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_pages.dart';
import 'config/routes/app_routes.dart';
import 'config/translations.dart';
import 'controllers/api_controller.dart';
import 'controllers/funcController.dart';
import 'controllers/init_notification.dart';
import 'controllers/theme_controller.dart';
import 'firebase_options.dart';
import 'modules/ad_posting/controllers/ad_posting_controller.dart';
import 'modules/favorites/controllers/favorites_controller.dart';
import 'modules/main/controllers/main_controller.dart';
import 'modules/profile/controllers/profile_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // GetStorage ni ishga tushirish
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize controllers before runApp
  Get.put(ThemeController());
  Get.put(FuncController());
  Get.put(ProfileController());
  Get.put(ApiController());
  Get.put(MainController());
  Get.put(AdPostingController());
  Get.put(FavoritesController());
  Get.put(MessagesController());


  await InitNotification.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() {
          return GetMaterialApp(
            title: 'Ishtopchi',
            theme: themeController.lightTheme,
            darkTheme: themeController.darkTheme,
            themeMode: themeController.themeMode.value,
            initialRoute: AppRoutes.splash,
            getPages: AppPages.pages,
            debugShowCheckedModeBanner: false,
            translations: AppTranslations(),
            locale: const Locale('uz'),
            fallbackLocale: const Locale('uz'),
          );
        });
      },
    );
  }
}
