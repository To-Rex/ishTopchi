import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'app_ui.dart';

/// "Siz roʻyxatdan oʻtmagansiz" holati.
///
/// Mehmon rejimida kirish talab qiladigan boʻlimlarda koʻrsatiladi.
/// Gradiyent va yorugʻlik soyasi olib tashlandi — tekis rang va nozik
/// kontur qoldi.
class NotLogged extends StatefulWidget {
  const NotLogged({super.key});

  @override
  State<NotLogged> createState() => _NotLoggedState();
}

class _NotLoggedState extends State<NotLogged>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    // 0.5 dan boshlash juda keskin edi — 0.88 yumshoqroq koʻtarilish
    // beradi.
    _scaleAnimation = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
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

    return SizedBox.expand(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.onSurface.withValues(alpha: 0.10),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      LucideIcons.userCheck,
                      size: 44,
                      color: colors.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              AppReveal(
                delay: const Duration(milliseconds: 120),
                child: Text(
                  "Siz ro‘yxatdan o‘tmagansiz".tr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 10),
              AppReveal(
                delay: const Duration(milliseconds: 180),
                child: Text(
                  "Iltimos, hisobingizga kiring yoki ro‘yxatdan o‘ting".tr,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              AppReveal(
                delay: const Duration(milliseconds: 240),
                child: AppButton(
                  label: "Ro‘yxatdan o‘ting va boshlang!".tr,
                  leading: const Icon(LucideIcons.logIn),
                  filled: true,
                  onPressed: () => Get.offNamed('/login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
