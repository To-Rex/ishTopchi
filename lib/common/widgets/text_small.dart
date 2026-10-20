import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Kichik matn.
///
/// API oʻzgarmadi. [TextLarge] dagi kabi ikki tuzatish: mavjud boʻlmagan
/// `Schyler` shrifti olib tashlandi va standart rang mavzudan olinadi.
class TextSmall extends StatelessWidget {
  final String text;
  final Color? color;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int maxLines;
  final double? fontSize;
  final double? letterSpacing;

  const TextSmall({
    super.key,
    required this.text,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1,
    this.fontSize,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text.tr,
      style: (theme.textTheme.bodyLarge ?? const TextStyle()).copyWith(
        color: color ?? theme.colorScheme.onSurface,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
