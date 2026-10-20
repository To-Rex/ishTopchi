import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../common/widgets/bottom_sheets.dart';
import '../controllers/onboarding_controller.dart';

/// Tanishtiruv ekrani.
///
/// Toʻrt qadam ilgari toʻrt marta nusxalangan `PageViewModel` sifatida
/// yozilgan edi; endi roʻyxatdan quriladi. Gradiyent fon, matn soyalari
/// va qattiq HEX ranglar olib tashlandi.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final OnboardingController controller = OnboardingController();

  /// Qadamlar: sarlavha, matn va belgi.
  static const List<({String title, String body, IconData icon})> _steps = [
    (
      title: "Ishtopchi bilan ish toping!",
      body: "Eng yaxshi ish e’lonlarini toping va o‘z karyerangizni boshlang.",
      icon: LucideIcons.briefcaseBusiness,
    ),
    (
      title: "E’lon joylashtiring",
      body: "Ish beruvchi sifatida o‘z e’lonlaringizni osongina joylashtiring.",
      icon: LucideIcons.filePlus,
    ),
    (
      title: "Qulay interfeys",
      body: "Zamonaviy dizayn va foydalanish uchun qulay platforma.",
      icon: LucideIcons.smartphone,
    ),
    (
      title: "Xavfsiz kirish",
      body: "Google yoki Telegram orqali tez va xavfsiz ro‘yxatdan o‘ting.",
      icon: LucideIcons.shieldCheck,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.languages),
            onPressed: () => BottomSheets().showLanguageBottomSheet(context),
            tooltip: 'Tilni o‘zgartirish'.tr,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Container(
          // Qurilma chetlarini hisobga olish
          margin: EdgeInsets.only(bottom: Platform.isAndroid ? 50 : 0),
          child: IntroductionScreen(
            pages: [
              for (final step in _steps)
                PageViewModel(
                  titleWidget: Text(
                    step.title.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  bodyWidget: Text(
                    step.body.tr,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  image: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _StepMark(icon: step.icon),
                  ),
                  decoration: PageDecoration(
                    pageColor: Colors.transparent,
                    bodyPadding: const EdgeInsets.symmetric(horizontal: 28),
                    imagePadding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.10,
                    ),
                  ),
                ),
            ],
            done: _PillButton(label: "Boshlash".tr, filled: true),
            onDone: controller.completeOnboarding,
            showSkipButton: true,
            skip: _PillButton(label: "O‘tkazib yuborish".tr, filled: false),
            next: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
              child: Icon(
                Icons.arrow_forward,
                color: colors.onPrimary,
                size: 20,
              ),
            ),
            dotsDecorator: DotsDecorator(
              activeColor: colors.primary,
              color: colors.onSurface.withValues(alpha: 0.22),
              size: const Size(8, 8),
              activeSize: const Size(20, 8),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              spacing: const EdgeInsets.symmetric(horizontal: 4),
            ),
            globalBackgroundColor: Colors.transparent,
            animationDuration: 400,
          ),
        ),
      ),
    );
  }
}

/// Qadam belgisi — dumaloq yuza ichidagi ikonka.
class _StepMark extends StatelessWidget {
  const _StepMark({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: colors.onSurface.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: colors.onSurface.withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 58,
          color: colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

/// Pastdagi "Boshlash" va "Oʻtkazib yuborish" tugmalari.
class _PillButton extends StatelessWidget {
  const _PillButton({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      alignment: Alignment.center,
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: filled ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border:
            filled
                ? null
                : Border.all(
                  color: colors.onSurface.withValues(alpha: 0.22),
                  width: 1.2,
                ),
      ),
      child: Text(
        label,
        maxLines: 1,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color:
              filled
                  ? colors.onPrimary
                  : colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
