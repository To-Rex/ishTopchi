import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

class CustomCard extends StatelessWidget {
  final Widget child;

  const CustomCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.darkBlue,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.scaleWidth(12, context)),
      ),
      child: Padding(
        padding: EdgeInsets.all(Responsive.scaleWidth(16, context)),
        child: child,
      ),
    );
  }
}
