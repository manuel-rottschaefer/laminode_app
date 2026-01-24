import 'package:flutter/material.dart';

class HexNodeLayoutData {
  final Size hexSize;
  final double cornerRadius;
  final double effectiveEdge;
  final List<double> lineWidths;
  final List<String> lines;
  final double circumradius;
  final double span;
  // Visual fields
  final Color centerColor;
  final Color edgeColor;
  final Color borderColor;
  final double borderWidth;
  final String? topmostLayerName;
  final bool debugLineWidth;

  HexNodeLayoutData({
    required this.hexSize,
    required this.cornerRadius,
    required this.effectiveEdge,
    required this.lineWidths,
    required this.lines,
    required this.circumradius,
    required this.span,
    required this.centerColor,
    required this.edgeColor,
    required this.borderColor,
    required this.borderWidth,
    this.topmostLayerName,
    this.debugLineWidth = false,
  });
}

class OctagonNodeLayoutData {
  final Size nodeSize;
  final double cornerRadius;
  final double effectiveEdge;
  final List<double> lineWidths;
  final List<String> lines;
  final double circumradius;
  final double span;
  // Visual fields
  final Color centerColor;
  final Color edgeColor;
  final Color borderColor;
  final double borderWidth;
  final String? topmostLayerName;
  final bool debugLineWidth;
  final bool flatBackground;

  OctagonNodeLayoutData({
    required this.nodeSize,
    required this.cornerRadius,
    required this.effectiveEdge,
    required this.lineWidths,
    required this.lines,
    required this.circumradius,
    required this.span,
    required this.centerColor,
    required this.edgeColor,
    required this.borderColor,
    required this.borderWidth,
    this.topmostLayerName,
    this.debugLineWidth = false,
    this.flatBackground = false,
  });
}
