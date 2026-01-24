import 'package:flutter/material.dart';

class LamiHexagonNode extends StatelessWidget {
  final Widget child;
  final Color color;
  final Color borderColor;
  final bool isSelected;
  final double size;
  final VoidCallback? onTap;

  const LamiHexagonNode({
    super.key,
    required this.child,
    required this.color,
    required this.borderColor,
    this.isSelected = false,
    this.size = 80.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Hexagon width/height ratio:
    // For pointy topped: Width = sqrt(3) * Radius, Height = 2 * Radius
    // Ratio W/H = sqrt(3)/2 ~= 0.866

    final width = size * 0.866;
    final height = size;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(width, height),
            painter: _HexagonPainter(
              color: color,
              borderColor: borderColor,
              isSelected: isSelected,
            ),
          ),
          SizedBox(
            width: width * 0.9, // Padding
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final bool isSelected;

  _HexagonPainter({
    required this.color,
    required this.borderColor,
    required this.isSelected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3.0 : 1.5;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Regular Pointy-Topped Hexagon
    // Center at (w/2, h/2)
    // Points at 30, 90, 150, 210, 270, 330 degrees

    // Actually, simple polygon calculation:
    // P0: (w/2, 0) - Top Center? No, that's flat topped turned 90.
    // Pointy topped: Top point is at (w/2, 0)

    path.moveTo(w / 2, 0); // Top
    path.lineTo(w, h * 0.25); // Top Right
    path.lineTo(w, h * 0.75); // Bottom Right
    path.lineTo(w / 2, h); // Bottom
    path.lineTo(0, h * 0.75); // Bottom Left
    path.lineTo(0, h * 0.25); // Top Left
    path.close();

    // Shadow?
    if (!isSelected) {
      canvas.drawShadow(path, Colors.black, 3.0, true);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.isSelected != isSelected;
  }
}
