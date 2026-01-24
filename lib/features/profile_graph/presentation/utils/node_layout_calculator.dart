import 'package:flutter/material.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/hex_layout_calculator.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/octagon_layout_calculator.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_data.dart';

export 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_data.dart';

class NodeLayoutCalculator {
  static HexNodeLayoutData computeHex({
    required String title,
    required double edgeLength,
    required int level,
    required double cornerRadiusFactor,
    required TextStyle titleStyle,
    required BuildContext context,
    required Color baseColor,
    required bool isFocused,
    required String id,
    String? topmostLayerName,
    bool debugLineWidth = false,
  }) {
    return HexLayoutCalculator.compute(
      title: title,
      edgeLength: edgeLength,
      level: level,
      cornerRadiusFactor: cornerRadiusFactor,
      titleStyle: titleStyle,
      baseColor: baseColor,
      isFocused: isFocused,
      topmostLayerName: topmostLayerName,
      debugLineWidth: debugLineWidth,
    );
  }

  static OctagonNodeLayoutData computeOctagon({
    required String title,
    required double edgeLength,
    required int level,
    required double cornerRadiusFactor,
    required TextStyle titleStyle,
    required BuildContext context,
    required Color baseColor,
    required bool isFocused,
    bool isBranching = false,
    required String id,
    String? topmostLayerName,
    bool debugLineWidth = false,
    bool flatBackground = false,
  }) {
    return OctagonLayoutCalculator.compute(
      title: title,
      edgeLength: edgeLength,
      level: level,
      cornerRadiusFactor: cornerRadiusFactor,
      titleStyle: titleStyle,
      baseColor: baseColor,
      isFocused: isFocused,
      isBranching: isBranching,
      topmostLayerName: topmostLayerName,
      debugLineWidth: debugLineWidth,
      flatBackground: flatBackground,
    );
  }
}
