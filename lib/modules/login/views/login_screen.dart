import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../common/widgets/app_ui.dart';
import '../../../config/routes/app_routes.dart';
import '../controllers/login_controller.dart';

/// Kirish ekrani.
///
/// Ekranda faqat kerakli narsa turadi: nom, tavsif va kirish yoʻllari.
/// Bezak shakl, gradiyent va soya yoʻq.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // Kontroller State ichida saqlanadi, shuning uchun qayta qurishda
  // yangidan yaratilmaydi.
  final LoginController controller = LoginController();

  @override
  Widget build(BuildContext context) {
    // Oqimning boshi — orqaga qaytish yoʻq, yuqori panel ham kerak emas.
    return AppScreen(
      showBack: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final theme = Theme.of(context);
          final colors = theme.colorScheme;
          final height = constraints.maxHeight;
          // Kompozitsiya nisbatlarga qurilgan, lekin kichik va juda baland
          // ekranlarda buzilmasligi uchun chegaralangan.
          final topGap = (height * 0.14).clamp(28.0, 120.0);
          final midGap = (height * 0.18).clamp(36.0, 180.0);

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: topGap),
                    AppReveal(
                      // Brend nomi — oqimdagi eng yirik matn.
                      child: Text(
                        'Ishtopchi'.tr,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontSize: 44,
                          height: 1.0,
                          letterSpacing: -1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppReveal(
                      delay: const Duration(milliseconds: 60),
                      child: Text(
                        'Ish e’lonlari platformasi'.tr,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          color: colors.onSurface.withValues(alpha: 0.58),
                        ),
                      ),
                    ),
                    SizedBox(height: midGap),
                    _buildLoadingLine(colors),
                    const SizedBox(height: 14),
                    _buildActions(),
                    const SizedBox(height: 20),
                    _buildCaption(theme, colors),
                    const SizedBox(height: 18),
                    _buildGuestLink(colors),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Yuklanish chizigʻi.
  ///
  /// Tinch holatda koʻrinmaydi, lekin joyini egallab turadi — shuning uchun
  /// yuklanish boshlanganda kompozitsiya siljimaydi.
  Widget _buildLoadingLine(ColorScheme colors) {
    return Obx(() {
      final loading = controller.isLoading.value;
      return SizedBox(
        height: 2,
        child:
            loading
                ? LinearProgressIndicator(
                  minHeight: 2,
                  backgroundColor: colors.onSurface.withValues(alpha: 0.12),
                  color: colors.onSurface,
                )
                : const SizedBox.shrink(),
      );
    });
  }

  /// Uchta kirish tugmasi.
  ///
  /// Platforma shartlari va chaqiriladigan metodlar avvalgidek saqlangan:
  /// Google — Android va iOS'da, iOS'da `signInWithGoogle`, aks holda
  /// `signInWithGoogle1`; Apple — faqat iOS; Telegram — hamma joyda.
  Widget _buildActions() {
    return Obx(() {
      final loading = controller.isLoading.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (Platform.isAndroid || Platform.isIOS)
            AppReveal(
              delay: const Duration(milliseconds: 140),
              child: AppButton(
                label: 'Google bilan kirish'.tr,
                leading: const FaIcon(FontAwesomeIcons.google),
                loading: loading,
                onPressed:
                    loading
                        ? null
                        : Platform.isIOS
                        ? controller.signInWithGoogle
                        : controller.signInWithGoogle1,
              ),
            ),
          if (Platform.isIOS) const SizedBox(height: 12),
          if (Platform.isIOS)
            AppReveal(
              delay: const Duration(milliseconds: 180),
              child: AppButton(
                label: 'Apple bilan kirish'.tr,
                leading: const FaIcon(FontAwesomeIcons.apple),
                loading: loading,
                onPressed: loading ? null : controller.signInWithApple,
              ),
            ),
          const SizedBox(height: 12),
          AppReveal(
            delay: const Duration(milliseconds: 220),
            child: AppButton(
              label: 'Telegram bilan kirish'.tr,
              leading: const FaIcon(FontAwesomeIcons.telegram),
              loading: loading,
              // Asosiy yoʻl — toʻldirilgan tugma. Avvalgi dizaynda ham
              // Telegram yagona toʻldirilgan tugma edi.
              filled: true,
              onPressed: loading ? null : controller.signInWithTelegram,
            ),
          ),
        ],
      );
    });
  }

  /// Avvalgidek — bosilmaydigan izoh matni.
  Widget _buildCaption(ThemeData theme, ColorScheme colors) {
    return AppReveal(
      delay: const Duration(milliseconds: 280),
      child: Text(
        'Yangi foydalanuvchi? Ro‘yxatdan o‘ting'.tr,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.58),
        ),
      ),
    );
  }

  /// Mehmon rejimi: roʻyxatdan oʻtmasdan ilovaga kirish.
  Widget _buildGuestLink(ColorScheme colors) {
    return AppReveal(
      delay: const Duration(milliseconds: 320),
      child: Align(
        child: TextButton(
          onPressed: () => Get.offNamed(AppRoutes.main),
          style: TextButton.styleFrom(foregroundColor: colors.onSurface),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Davom etish'.tr),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                size: 16,
                color: colors.onSurface.withValues(alpha: 0.58),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
