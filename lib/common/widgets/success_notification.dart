import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

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

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
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
                child: Container(
                  padding: EdgeInsets.all(Responsive.scaleWidth(24, context)),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          Responsive.scaleWidth(16, context),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.circleCheck,
                          color: AppColors.green,
                          size: Responsive.scaleFont(48, context),
                        ),
                      ),
                      SizedBox(height: Responsive.scaleHeight(16, context)),
                      Text(
                        'E’lon muvaffaqiyatli joylandi'.tr,
                        style: TextStyle(
                          fontSize: Responsive.scaleFont(16, context),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Overlay widget for showing success notification
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
      backgroundColor: Colors.black.withOpacity(0.3),
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: SuccessNotification(
          onAnimationComplete: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
        ),
      ),
    );
  }
}
