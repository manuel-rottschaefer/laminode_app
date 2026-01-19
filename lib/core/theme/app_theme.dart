import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class LamiTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: LamiColors.darkScaffoldBackground,
    textTheme: _buildTextTheme(Brightness.dark),
    colorScheme: const ColorScheme.dark(
      primary: LamiColors.darkPrimary,
      secondary: LamiColors.darkSecondary,
      surface: LamiColors.darkSurface,
      surfaceContainer: LamiColors.darkSurfaceContainer,
      surfaceContainerHighest: LamiColors.darkSurfaceContainerHighest,
      onSurface: LamiColors.darkOnSurface,
      outline: LamiColors.darkOutline,
      primaryContainer: LamiColors.darkPrimaryContainer,
    ),
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.dark
        ? GoogleFonts.interTextTheme(
            const TextTheme(
              displayLarge: TextStyle(color: Color(0xFFE8E8E8)),
              displayMedium: TextStyle(color: Color(0xFFE0E0E0)),
              displaySmall: TextStyle(color: Color(0xFFD0D0D0)),
              labelSmall: TextStyle(color: Color(0xFF787878)),
            ),
          )
        : GoogleFonts.interTextTheme();

    return baseTheme.copyWith(
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}
