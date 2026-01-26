import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_data.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_helper.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/profile_graph_config.dart';

class HexLayoutCalculator with NodeLayoutHelper {
  static Color _centerColor(Color baseColor, int level) {
    final hsl = HSLColor.fromColor(baseColor);
    final centerLightness = (hsl.lightness - 0.1 * level).clamp(0.0, 1.0);
    return hsl.withLightness(centerLightness).toColor();
  }

  static Color _edgeColor(Color baseColor, int level) {
    final center = _centerColor(baseColor, level);
    final edgeHsl = HSLColor.fromColor(center);
    return edgeHsl
        .withLightness((edgeHsl.lightness - 0.30).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _borderColor(Color baseColor, int level, bool isFocused) {
    var borderColor = _edgeColor(baseColor, level);
    if (isFocused) {
      final hh = HSLColor.fromColor(borderColor);
      borderColor = hh
          .withLightness((hh.lightness + 0.3).clamp(0.0, 1.0))
          .toColor();
    }
    return borderColor;
  }

  static HexNodeLayoutData compute({
    required String title,
    required double edgeLength,
    required int level,
    required double cornerRadiusFactor,
    required TextStyle titleStyle,
    required Color baseColor,
    required bool isFocused,
    String? topmostLayerName,
    bool debugLineWidth = false,
  }) {
    final effectiveEdge =
        (edgeLength * math.pow(ProfileGraphConfig.nodeLevelScaleFactor, level))
            .toDouble();
    final w = 2 * effectiveEdge;
    final h =
        math.sqrt(3) *
        effectiveEdge *
        ProfileGraphConfig.hexHeightFactor *
        ProfileGraphConfig.hexScaleY;
    final hexSize = Size(w, h);
    final cornerRadius = effectiveEdge * cornerRadiusFactor;

    final borderWidth = (ProfileGraphConfig.maxBorderWidth - 2.0 * level).clamp(
      0.0,
      ProfileGraphConfig.maxBorderWidth,
    );
    final r = effectiveEdge - borderWidth - cornerRadius;
    final circumradius = r;

    final span = math.sqrt(3) * r * ProfileGraphConfig.hexSpanFactor;

    final presets = <int, List<double>>{
      1: [1],
      2: [1.05, 0.9],
      3: [1, 1.05, 0.9],
      4: [1.1, 1.2, 1.1, 1.4],
    };

    List<double> widthsForCount(int count) {
      final multipliers = presets[count] ?? presets[4]!;
      return multipliers
          .map((m) => (m * effectiveEdge).clamp(30.0, w - 40.0).toDouble())
          .toList();
    }

    final words = NodeLayoutHelper.getWords(title);

    for (int linesCount = 1; linesCount <= 4; linesCount++) {
      var ws = widthsForCount(linesCount);
      final fit = NodeLayoutHelper.tryFitWithoutEllipsis(words, titleStyle, ws);
      if (fit != null) {
        return HexNodeLayoutData(
          hexSize: hexSize,
          cornerRadius: cornerRadius,
          effectiveEdge: effectiveEdge,
          lineWidths: ws,
          lines: fit,
          circumradius: circumradius,
          span: span,
          centerColor: _centerColor(baseColor, level),
          edgeColor: _edgeColor(baseColor, level),
          borderColor: _borderColor(baseColor, level, isFocused),
          borderWidth: borderWidth,
          topmostLayerName: topmostLayerName,
          debugLineWidth: debugLineWidth,
        );
      }
    }

    final fallbackWs = widthsForCount(4);
    final fallback = NodeLayoutHelper.buildFallbackWithEllipsis(
      words,
      titleStyle,
      fallbackWs,
    );

    return HexNodeLayoutData(
      hexSize: hexSize,
      cornerRadius: cornerRadius,
      effectiveEdge: effectiveEdge,
      lineWidths: fallbackWs,
      lines: fallback,
      circumradius: circumradius,
      span: span,
      centerColor: _centerColor(baseColor, level),
      edgeColor: _edgeColor(baseColor, level),
      borderColor: _borderColor(baseColor, level, isFocused),
      borderWidth: borderWidth,
      topmostLayerName: topmostLayerName,
      debugLineWidth: debugLineWidth,
    );
  }
}
