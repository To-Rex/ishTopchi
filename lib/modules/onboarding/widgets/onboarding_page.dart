import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_dimensions.dart';
import '../../../core/utils/responsive.dart';

class OnboardingPage extends StatefulWidget {
  final String title;
  final String body;
  final IconData icon;

  const OnboardingPage({super.key, required this.title, required this.body, required this.icon});

  @override
  OnboardingPageState createState() => OnboardingPageState();
}

class OnboardingPageState extends State<OnboardingPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: Icon(
            widget.icon,
            size: Responsive.scaleWidth(AppDimensions.iconSizeLarge, context),
            color: AppColors.lightGray,
          ),
        ),
        SizedBox(height: Responsive.scaleHeight(60, context)),
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: Responsive.scaleFont(34, context),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.scaleHeight(16, context)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.scaleWidth(AppDimensions.paddingLarge, context),
          ),
          child: Text(
            widget.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: Responsive.scaleFont(16, context),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}