import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_pages.dart';
import 'config/routes/app_routes.dart';
import 'controllers/api_controller.dart';
import 'controllers/funcController.dart';
import 'firebase_options.dart';
import 'modules/favorites/controllers/favorites_controller.dart';
import 'modules/favorites/views/favorites_screen.dart';
import 'modules/main/controllers/main_controller.dart';
import 'modules/profile/controllers/profile_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  Get.put(FuncController());
  Get.lazyPut(() => ProfileController());
  Get.put(ApiController());
  Get.put(MainController());


  Get.put(FavoritesController());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ishtopchi',
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}