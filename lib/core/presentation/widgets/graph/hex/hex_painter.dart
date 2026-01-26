import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/graph/shape_utils.dart';

class HexPainter extends CustomPainter {
  final Path? path;
  final Color fillCenter;
  final Color fillEdge;
  final Color stroke;
  final double strokeWidth;
  final double cornerRadius;
  final double scaleY;
  final double rotationDegrees;
  final bool onlyFill;
  final bool onlyStroke;
  final bool isDashed;

  HexPainter({
    this.path,
    required this.fillCenter,
    required this.fillEdge,
    required this.stroke,
    required this.strokeWidth,
    this.cornerRadius = 8.0,
    this.scaleY = 0.95,
    this.rotationDegrees = 0.0,
    this.onlyFill = false,
    this.onlyStroke = false,
    this.isDashed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use provided path or rebuild if missing
    final hexPath =
        path ??
        ShapePathUtils.getHexPath(
          size,
          strokeWidth: strokeWidth,
          cornerRadius: cornerRadius,
          scaleY: scaleY,
          rotationDegrees: rotationDegrees,
        );

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    if (!onlyStroke) {
      // For a flat-top hexagon, the circumradius is w/2
      final r = (w / 2) - strokeWidth - cornerRadius;
      final center = Offset(cx, cy);
      // Ensure gradient radius is positive
      final gradRadius = (r * 1.0 + cornerRadius).clamp(1.0, 1000.0);
      final shader = ui.Gradient.radial(
        center,
        gradRadius,
        [fillCenter, fillEdge],
        [0.0, 1.0],
        ui.TileMode.clamp,
      );

      final paintFill = Paint()
        ..shader = shader
        ..isAntiAlias = true;

      canvas.save();
      canvas.clipPath(hexPath);
      final rect = Rect.fromLTWH(0, 0, w, h);
      canvas.drawRect(rect, paintFill);
      canvas.restore();
    }

    if (!onlyFill) {
      final paintStroke = Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;

      if (isDashed) {
        final pathMetrics = hexPath.computeMetrics();
        for (final metric in pathMetrics) {
          const dashWidth = 12.0;
          const dashSpace = 8.0;
          double distance = 0.0;
          while (distance < metric.length) {
            final nextDistance = distance + dashWidth;
            final extract = metric.extractPath(
              distance,
              nextDistance.clamp(0.0, metric.length),
            );
            canvas.drawPath(extract, paintStroke);
            distance = nextDistance + dashSpace;
          }
        }
      } else {
        canvas.drawPath(hexPath, paintStroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HexPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.fillCenter != fillCenter ||
        oldDelegate.fillEdge != fillEdge ||
        oldDelegate.stroke != stroke ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.scaleY != scaleY ||
        oldDelegate.rotationDegrees != rotationDegrees ||
        oldDelegate.onlyFill != onlyFill ||
        oldDelegate.onlyStroke != onlyStroke ||
        oldDelegate.isDashed != isDashed;
  }
}
