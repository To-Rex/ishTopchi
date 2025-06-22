import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_pages.dart';
import 'config/routes/app_routes.dart';
import 'controllers/funcController.dart';
import 'firebase_options.dart';
import 'modules/profile/controllers/profile_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
  Get.put(FuncController());
  Get.lazyPut(() => ProfileController());
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