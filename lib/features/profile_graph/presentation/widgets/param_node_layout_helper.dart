import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_colors.dart';

class ParamNodeLayoutHelper {
  static Color getCategoryColor(String colorName) {
    return LamiColor.fromString(colorName).value;
  }

  static const titleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
