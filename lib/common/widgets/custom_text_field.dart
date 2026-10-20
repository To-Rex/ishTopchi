import 'package:flutter/material.dart';

/// Umumiy matn maydoni.
///
/// Uslub endi bu yerda emas, [AppTheme] ning `inputDecorationTheme` sida
/// belgilangan — shuning uchun ilovadagi barcha maydonlar, shu jumladan
/// bu widgetdan foydalanmaydiganlari ham, bir xil koʻrinadi.
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}
