import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../core/utils/responsive.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: AppColors.lightBlue),
        hintStyle: TextStyle(color: AppColors.lightBlue.withOpacity(0.6)),
        filled: true,
        fillColor: AppColors.darkNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: Responsive.scaleHeight(16, context),
          horizontal: Responsive.scaleWidth(20, context),
        ),
      ),
      style: TextStyle(color: AppColors.lightGray),
    );
  }
}
