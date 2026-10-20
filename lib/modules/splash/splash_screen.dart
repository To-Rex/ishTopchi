import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/routes/app_routes.dart';
import '../../controllers/funcController.dart';

/// Ochilish ekrani.
///
/// Brend nomi yumshoq paydo boʻladi va biroz koʻtariladi, tagida esa
/// nozik chiziq kengayadi — kutish vaqti "toʻxtab qolgan" emas, "ishlab
/// turgan" boʻlib tuyuladi.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  final funcController = Get.put(FuncController());

  @override
  void initState() {
    super.initState();

    // Log FCM token for debugging/testing
    funcController.logFcmToken();

    funcController.checkAndHandleDevice();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 2), () {
      final token = funcController.getToken();
      if (token != null && token.isNotEmpty) {
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.offAllNamed(AppRoutes.main);
        //Get.offAll(() => const OnboardingScreen(), transition: Transition.fadeIn, duration: const Duration(seconds: 1));
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _opacityAnimation.value;
            return Opacity(
              opacity: t,
              child: Transform.translate(
                // Matn 10 piksel pastdan koʻtariladi — faqat soʻnishdan
                // koʻra tirikroq koʻrinadi.
                offset: Offset(0, 10 * (1 - t)),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ishtopchi',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontSize: 42,
                  letterSpacing: -1.4,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 18),
              // Kengayib boradigan nozik chiziq — yuklanish davom
              // etayotganini bildiradi, lekin spinner kabi diqqatni
              // tortmaydi.
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1900),
                curve: Curves.easeInOut,
                builder: (context, value, _) {
                  return Container(
                    width: 120 * value,
                    height: 2,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
