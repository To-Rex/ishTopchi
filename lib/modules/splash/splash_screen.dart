import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_colors.dart';
import '../../controllers/funcController.dart';
import '../main/views/main_screen.dart';
import '../onboarding/views/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  final funcController = Get.put(FuncController());

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 1), () {
      final token = funcController.getToken();
      if (token != null && token.isNotEmpty) {
        Get.offNamed(AppRoutes.main);
        Get.off(() => const MainScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(seconds: 1),
        );
      } else {
        //Get.offNamed(AppRoutes.onboarding);
        Get.off(() => const OnboardingScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(seconds: 1),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Text(
            'Ishtopchi',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: AppColors.lightBlue,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}