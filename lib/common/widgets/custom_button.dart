import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import '../../core/utils/responsive.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? iconSize;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.iconSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLoading || onPressed == null ? 0.6 : 1.0,
      duration: Duration(milliseconds: 300),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: icon != null
            ? AnimatedContainer(
          duration: Duration(milliseconds: 200),
          transform: isLoading ? Matrix4.identity() : Matrix4.diagonal3Values(1.1, 1.1, 1),
          child: Icon(
            icon,
            color: textColor ?? AppColors.lightGray,
            size: iconSize ?? Responsive.scaleWidth(AppDimensions.iconSizeMedium, context),
          ),
        )
            : SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(
            fontSize: Responsive.scaleFont(16, context),
            fontWeight: FontWeight.w700,
            color: textColor ?? AppColors.lightGray,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.midBlue,
          padding: EdgeInsets.symmetric(
            vertical: Responsive.scaleHeight(16, context),
            horizontal: Responsive.scaleWidth(24, context),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 10,
          minimumSize: Size(double.infinity, Responsive.scaleHeight(AppDimensions.buttonHeight, context)),
          shadowColor: Colors.black45,
        ),
      ),
    );
  }
}