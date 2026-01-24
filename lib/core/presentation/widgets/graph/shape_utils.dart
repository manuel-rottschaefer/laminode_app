import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShapePathUtils {
  static Path getOctagonPath(
    Size size, {
    required double strokeWidth,
    required double cornerRadius,
    double scaleY = 1.0,
    double rotationDegrees = 22.5,
  }) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = (math.min(w, h) / 2) - strokeWidth - cornerRadius;

    final pts = <Offset>[];
    for (int i = 0; i < 8; i++) {
      final angle = (math.pi / 180) * (45 * i + rotationDegrees);
      pts.add(
        Offset(cx + r * math.cos(angle), cy + (r * math.sin(angle)) * scaleY),
      );
    }

    return _buildRoundedPath(pts, cornerRadius);
  }

  static Path getHexPath(
    Size size, {
    required double strokeWidth,
    required double cornerRadius,
    double scaleY = 1.0,
    double rotationDegrees = 0.0,
  }) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = (w / 2) - strokeWidth - cornerRadius;

    final pts = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 180) * (60 * i + rotationDegrees);
      pts.add(
        Offset(cx + r * math.cos(angle), cy + (r * math.sin(angle)) * scaleY),
      );
    }

    return _buildRoundedPath(pts, cornerRadius);
  }

  static Path _buildRoundedPath(List<Offset> pts, double cornerRadius) {
    final path = Path();
    if (pts.isEmpty) return path;

    for (int i = 0; i < pts.length; i++) {
      final prev = pts[(i - 1 + pts.length) % pts.length];
      final curr = pts[i];
      final next = pts[(i + 1) % pts.length];

      final v1 = (curr - prev);
      final v2 = (next - curr);
      final len1 = v1.distance;
      final len2 = v2.distance;
      final safeRadius = math.min(cornerRadius, math.min(len1, len2) / 2);

      final p1 = curr - (v1 / len1) * safeRadius;
      final p2 = curr + (v2 / len2) * safeRadius;

      if (i == 0) {
        path.moveTo(p1.dx, p1.dy);
      } else {
        path.lineTo(p1.dx, p1.dy);
      }
      path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
    }
    path.close();
    return path;
  }
}
