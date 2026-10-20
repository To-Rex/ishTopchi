import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_theme.dart';

/// Muvaffaqiyat xabari.
///
/// `elasticOut` sakrashi oʻrniga yumshoq `easeOutBack` — belgi bir marta
/// yengil "qadam tashlaydi", sakramaydi.
class SuccessNotification extends StatefulWidget {
  final VoidCallback? onAnimationComplete;

  const SuccessNotification({super.key, this.onAnimationComplete});

  @override
  State<SuccessNotification> createState() => _SuccessNotificationState();
}

class _SuccessNotificationState extends State<SuccessNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Auto-dismiss after 1.5-2 seconds
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          if (mounted) {
            widget.onAnimationComplete?.call();
          }
        });
      }
    });
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

    return Material(
      color: Colors.transparent,
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? colors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              // Soya oʻrniga kontur — qorongʻi fonda soya baribir
              // koʻrinmaydi.
              border: Border.all(
                color: colors.onSurface.withValues(alpha: 0.10),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.circleCheck,
                    color: AppColors.green,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'E’lon muvaffaqiyatli joylandi'.tr,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Muvaffaqiyat xabarini butun ekran ustida koʻrsatuvchi qatlam.
class SuccessNotificationOverlay extends StatelessWidget {
  final VoidCallback? onDismiss;

  const SuccessNotificationOverlay({super.key, this.onDismiss});

  static void show(BuildContext context, {VoidCallback? onDismiss}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return SuccessNotificationOverlay(onDismiss: onDismiss);
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        opaque: false,
        barrierDismissible: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fon xiralashtirish (`BackdropFilter`) olib tashlandi: u qimmat
      // va shishasimon koʻrinish beradi. Oddiy toʻq parda yetarli.
      backgroundColor: Colors.black.withValues(alpha: 0.42),
      body: SuccessNotification(
        onAnimationComplete: () {
          Navigator.of(context).pop();
          onDismiss?.call();
        },
      ),
    );
  }
}
