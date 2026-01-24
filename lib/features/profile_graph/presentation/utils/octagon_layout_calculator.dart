import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_data.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_helper.dart';

class OctagonLayoutCalculator with NodeLayoutHelper {
  static Color _centerColor(Color baseColor, int level) {
    final hsl = HSLColor.fromColor(baseColor);
    final centerLightness = (hsl.lightness - 0.1 * (level + 0.5)).clamp(
      0.0,
      1.0,
    );
    return hsl.withLightness(centerLightness).toColor();
  }

  static Color _edgeColor(Color baseColor, int level) {
    final center = _centerColor(baseColor, level);
    final edgeHsl = HSLColor.fromColor(center);
    return edgeHsl
        .withLightness((edgeHsl.lightness - 0.25).clamp(0.0, 1.0))
        .toColor();
  }

  static Color _borderColor(
    Color baseColor,
    int level,
    bool isFocused,
    bool isBranching,
  ) {
    final edge = _edgeColor(baseColor, level);
    if (isFocused || isBranching) {
      final hh = HSLColor.fromColor(edge);
      return hh.withLightness((hh.lightness + 0.3).clamp(0.0, 1.0)).toColor();
    }
    return edge;
  }

  static OctagonNodeLayoutData compute({
    required String title,
    required double edgeLength,
    required int level,
    required double cornerRadiusFactor,
    required TextStyle titleStyle,
    required Color baseColor,
    required bool isFocused,
    bool isBranching = false,
    String? topmostLayerName,
    bool debugLineWidth = false,
    bool flatBackground = false,
  }) {
    final effectiveEdge = (edgeLength * math.pow(0.95, level)).toDouble();
    final r = effectiveEdge;
    final apothem = r * math.cos(math.pi / 8);
    final w = 2 * apothem;
    final h = 2 * apothem;

    final nodeSize = Size(w, h);
    final cornerRadius = effectiveEdge * cornerRadiusFactor;

    final borderWidth = (6.0 - 2.0 * level).clamp(0.0, 6.0);
    final innerR = r - borderWidth - cornerRadius;
    final circumradius = innerR;
    final span = 2 * innerR * math.cos(math.pi / 8) * 0.9;

    final presets = <int, List<double>>{
      1: [1.1],
      2: [1.1, 1.1],
      3: [1.1, 1.2, 1.1],
      4: [1.1, 1.2, 1.2, 1.1],
    };

    List<double> widthsForCount(int count) {
      final multipliers = presets[count] ?? presets[4]!;
      return multipliers
          .map(
            (m) => (m * effectiveEdge * 0.9).clamp(30.0, w - 20.0).toDouble(),
          )
          .toList();
    }

    final words = NodeLayoutHelper.getWords(title);

    for (int linesCount = 1; linesCount <= 4; linesCount++) {
      var ws = widthsForCount(linesCount);
      final fit = NodeLayoutHelper.tryFitWithoutEllipsis(words, titleStyle, ws);
      if (fit != null) {
        return OctagonNodeLayoutData(
          nodeSize: nodeSize,
          cornerRadius: cornerRadius,
          effectiveEdge: effectiveEdge,
          lineWidths: ws,
          lines: fit,
          circumradius: circumradius,
          span: span,
          centerColor: flatBackground
              ? _edgeColor(baseColor, level)
              : _centerColor(baseColor, level),
          edgeColor: _edgeColor(baseColor, level),
          borderColor: _borderColor(baseColor, level, isFocused, isBranching),
          borderWidth: borderWidth,
          topmostLayerName: topmostLayerName,
          debugLineWidth: debugLineWidth,
          flatBackground: flatBackground,
        );
      }
    }

    final fallbackWs = widthsForCount(4);
    final fallback = NodeLayoutHelper.buildFallbackWithEllipsis(
      words,
      titleStyle,
      fallbackWs,
    );

    return OctagonNodeLayoutData(
      nodeSize: nodeSize,
      cornerRadius: cornerRadius,
      effectiveEdge: effectiveEdge,
      lineWidths: fallbackWs,
      lines: fallback,
      circumradius: circumradius,
      span: span,
      centerColor: flatBackground
          ? _edgeColor(baseColor, level)
          : _centerColor(baseColor, level),
      edgeColor: _edgeColor(baseColor, level),
      borderColor: _borderColor(baseColor, level, isFocused, isBranching),
      borderWidth: borderWidth,
      topmostLayerName: topmostLayerName,
      debugLineWidth: debugLineWidth,
      flatBackground: flatBackground,
    );
  }
}
