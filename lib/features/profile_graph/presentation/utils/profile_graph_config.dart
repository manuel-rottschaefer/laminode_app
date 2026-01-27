import 'package:flutter/material.dart';

class ProfileGraphConfig {
  static const double baseEdgeLength = 140.0; // Restored from legacy GraphNode.edgeLength
  static const double cornerRadiusFactorHex = 0.15;

  // Regular regular shapes
  static const double hexHeightFactor = 1.0;
  static const double hexScaleY = 1.0;
  static const double hexSpanFactor = 1.0;
  static const double octagonSpanFactor = 1.0;

  static const double edgeWidth = 4.0;
  static const double rootEdgeWidth = 1.5;
  static const Color rootEdgeColor = Color(0xFF757575); // grey.shade600

  static const double nodeLevelScaleFactor = 0.95;
  static const double maxBorderWidth = 6.0;
}