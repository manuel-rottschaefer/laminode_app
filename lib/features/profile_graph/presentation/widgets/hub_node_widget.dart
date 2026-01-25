import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import '../../domain/entities/graph_node.dart';
import 'dart:math' as math;

class HubNodeWidget extends StatelessWidget {
  final HubGraphNode node;
  final VoidCallback? onTap;

  const HubNodeWidget({super.key, required this.node, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: OctagonPainter(
          color: LamiColor.fromString(
            node.category.categoryColorName,
          ).value.withValues(alpha: 0.8),
          isFocused: node.isFocused,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            node.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class OctagonPainter extends CustomPainter {
  final Color color;
  final bool isFocused;

  OctagonPainter({required this.color, this.isFocused = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isFocused ? Colors.blue : Colors.black.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFocused ? 2 : 1;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h) * 0.3;

    path.moveTo(s, 0);
    path.lineTo(w - s, 0);
    path.lineTo(w, s);
    path.lineTo(w, h - s);
    path.lineTo(w - s, h);
    path.lineTo(s, h);
    path.lineTo(0, h - s);
    path.lineTo(0, s);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
