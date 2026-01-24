import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexNodeShape extends StatelessWidget {
  final Color color;
  final bool isHovered;
  final bool isSelected;
  final Color secondaryColor;
  final Widget? child;

  const HexNodeShape({
    super.key,
    required this.color,
    required this.isHovered,
    required this.isSelected,
    required this.secondaryColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HexNodePainter(
        color: color,
        isHovered: isHovered,
        isSelected: isSelected,
        secondaryColor: secondaryColor,
      ),
      child: child,
    );
  }
}

class OctagonNodeShape extends StatelessWidget {
  final Color color;
  final bool isHovered;
  final bool isSelected;
  final Color secondaryColor;
  final Widget? child;

  const OctagonNodeShape({
    super.key,
    required this.color,
    required this.isHovered,
    required this.isSelected,
    required this.secondaryColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OctagonNodePainter(
        color: color,
        isHovered: isHovered,
        isSelected: isSelected,
        secondaryColor: secondaryColor,
      ),
      child: child,
    );
  }
}

class _HexNodePainter extends CustomPainter {
  final Color color;
  final bool isHovered;
  final bool isSelected;
  final Color secondaryColor;

  _HexNodePainter({
    required this.color,
    required this.isHovered,
    required this.isSelected,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();

    for (var i = 0; i < 6; i++) {
      final angle = (i * 60) * (math.pi / 180);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    if (isSelected || isHovered) {
      final borderPaint = Paint()
        ..color = isSelected
            ? secondaryColor
            : secondaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3.0 : 2.0;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HexNodePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isHovered != isHovered ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}

class _OctagonNodePainter extends CustomPainter {
  final Color color;
  final bool isHovered;
  final bool isSelected;
  final Color secondaryColor;

  _OctagonNodePainter({
    required this.color,
    required this.isHovered,
    required this.isSelected,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final path = Path();

    for (var i = 0; i < 8; i++) {
      final angle = (i * 45 + 22.5) * (math.pi / 180);
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    if (isSelected || isHovered) {
      final borderPaint = Paint()
        ..color = isSelected
            ? secondaryColor
            : secondaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 3.0 : 2.0;
      canvas.drawPath(path, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OctagonNodePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.isHovered != isHovered ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
