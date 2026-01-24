import 'package:flutter/material.dart';
import 'dart:math' as math;

enum HexAnchor {
  center,
  // Edge midpoints (Flat-top orientation)
  topEdge,
  bottomEdge,
  topLeftEdge,
  topRightEdge,
  bottomLeftEdge,
  bottomRightEdge,
  // Vertices (Flat-top orientation)
  leftVertex,
  rightVertex,
  topLeftVertex,
  topRightVertex,
  bottomLeftVertex,
  bottomRightVertex,
}

class HexChild {
  final Widget child;
  final HexAnchor anchor;
  final Offset offset;

  HexChild({
    required this.child,
    this.anchor = HexAnchor.center,
    this.offset = Offset.zero,
  });
}

/// A robust layout engine for positioning children inside a regular hexagon.
/// Assumes flat-top orientation by default (0 degree rotation in RoundedHexPainter).
class HexLayout extends StatelessWidget {
  final List<HexChild> children;
  final double circumradius;
  final double scaleY;

  const HexLayout({
    super.key,
    required this.children,
    required this.circumradius,
    this.scaleY = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    // Distance from center to flat edge midpoints
    final double apothem = circumradius * math.cos(math.pi / 6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: children.map((hc) {
            Offset anchorPos;
            switch (hc.anchor) {
              case HexAnchor.center:
                anchorPos = center;
                break;

              // Edge Midpoints
              case HexAnchor.topEdge:
                // 270 degrees
                anchorPos = center + Offset(0, -apothem * scaleY);
                break;
              case HexAnchor.bottomEdge:
                // 90 degrees
                anchorPos = center + Offset(0, apothem * scaleY);
                break;
              case HexAnchor.topLeftEdge:
                // 210 degrees
                final angle = 210 * math.pi / 180;
                anchorPos =
                    center +
                    Offset(
                      apothem * math.cos(angle),
                      apothem * math.sin(angle) * scaleY,
                    );
                break;
              case HexAnchor.topRightEdge:
                // 330 degrees
                final angle = 330 * math.pi / 180;
                anchorPos =
                    center +
                    Offset(
                      apothem * math.cos(angle),
                      apothem * math.sin(angle) * scaleY,
                    );
                break;
              case HexAnchor.bottomLeftEdge:
                // 150 degrees
                final angle = 150 * math.pi / 180;
                anchorPos =
                    center +
                    Offset(
                      apothem * math.cos(angle),
                      apothem * math.sin(angle) * scaleY,
                    );
                break;
              case HexAnchor.bottomRightEdge:
                // 30 degrees
                final angle = 30 * math.pi / 180;
                anchorPos =
                    center +
                    Offset(
                      apothem * math.cos(angle),
                      apothem * math.sin(angle) * scaleY,
                    );
                break;

              // Vertices (Flat-Top)
              // 0 deg is right vertex
              case HexAnchor.rightVertex:
                anchorPos = center + Offset(circumradius, 0);
                break;
              case HexAnchor.leftVertex:
                anchorPos = center + Offset(-circumradius, 0);
                break;
              case HexAnchor.topRightVertex:
                // 300 deg
                final rad = 300 * math.pi / 180;
                anchorPos =
                    center +
                    Offset(
                      circumradius * math.cos(rad),
                      (circumradius * math.sin(rad)) * scaleY,
                    );
                break;
              case HexAnchor.topLeftVertex:
                // 240 deg
                final rad = 240 * math.pi / 180;
                anchorPos =
                    center +
                    Offset(
                      circumradius * math.cos(rad),
                      (circumradius * math.sin(rad)) * scaleY,
                    );
                break;
              case HexAnchor.bottomRightVertex:
                // 60 deg
                final rad = 60 * math.pi / 180;
                anchorPos =
                    center +
                    Offset(
                      circumradius * math.cos(rad),
                      (circumradius * math.sin(rad)) * scaleY,
                    );
                break;
              case HexAnchor.bottomLeftVertex:
                // 120 deg
                final rad = 120 * math.pi / 180;
                anchorPos =
                    center +
                    Offset(
                      circumradius * math.cos(rad),
                      (circumradius * math.sin(rad)) * scaleY,
                    );
                break;
            }

            // Adjust by offset and center the child itself if needed?
            // Usually, anchorPos is where we place the center of the child
            return Positioned(
              left: anchorPos.dx + hc.offset.dx,
              top: anchorPos.dy + hc.offset.dy,
              child: fractionalTranslation(
                offset: const Offset(-0.5, -0.5),
                child: hc.child,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget fractionalTranslation({
    required Offset offset,
    required Widget child,
  }) {
    return FractionalTranslation(translation: offset, child: child);
  }
}
