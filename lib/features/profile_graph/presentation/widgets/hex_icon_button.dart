import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/graph/hex/hex_painter.dart';

class HexIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isToggled;
  final double size;

  const HexIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.isToggled = false,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    // Always a slight black dim
    final backgroundColor = Colors.black.withValues(alpha: 0.3);

    // Grey if disabled (untoggled), White if enabled (toggled)
    final iconColor = isToggled
        ? Colors.white.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.6);

    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: CustomPaint(
          painter: HexPainter(
            fillCenter: backgroundColor,
            fillEdge: backgroundColor,
            stroke: isToggled
                ? Colors.white.withValues(alpha: 0.9)
                : Colors.transparent,
            strokeWidth: 1.5,
            cornerRadius: 4.0,
            rotationDegrees: 0, // Pointy top
          ),
          child: Center(
            child: enabled
                ? Icon(icon, size: size * 0.4, color: iconColor)
                : const SizedBox.shrink(), // Hide icon if disabled
          ),
        ),
      ),
    );
  }
}
