import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Yirik matn.
///
/// API oʻzgarmadi. Ikki narsa tuzatildi:
/// * `fontFamily: 'Schyler'` olib tashlandi — bu shrift `pubspec.yaml`
///   da umuman eʼlon qilinmagan, ya'ni hech qachon yuklanmagan;
/// * standart rang `Colors.black` edi — qorongʻi fonda koʻrinmasdi.
///   Endi rang berilmasa mavzudan olinadi.
class TextLarge extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int maxLines;
  final double? fontSize;

  const TextLarge({
    super.key,
    required this.text,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text.tr,
      style: (theme.textTheme.headlineSmall ?? const TextStyle()).copyWith(
        color: color ?? theme.colorScheme.onSurface,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
