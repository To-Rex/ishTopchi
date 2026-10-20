import 'package:flutter/material.dart';

/// Tanishtiruv sahifasining bitta qadami.
///
/// Ilgari ikonkaning soʻnish animatsiyasi `end: 0.5` bilan tugardi —
/// ya'ni ikonka yarim shaffof holatda qotib qolardi. Endi u toʻliq
/// chiqadi, xiralik esa rang orqali beriladi.
class OnboardingPage extends StatefulWidget {
  final String title;
  final String body;
  final IconData icon;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: colors.onSurface.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.onSurface.withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: 56,
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            widget.title,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            widget.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
