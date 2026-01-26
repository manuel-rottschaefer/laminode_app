import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_colors.dart';

class ParamNodeLayoutHelper {
  static Color getCategoryColor(String colorName) {
    return LamiColor.fromString(colorName).value;
  }

  static Color darken(Color c, int level) {
    if (level < 0) return c;
    final hsl = HSLColor.fromColor(c);
    // Darken by 10% per level, starting at 20%
    final double amount = (0.2 + (level * 0.1)).clamp(0.0, 1.0);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  static TextStyle getTitleStyle(BuildContext context) {
    return const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }
}
