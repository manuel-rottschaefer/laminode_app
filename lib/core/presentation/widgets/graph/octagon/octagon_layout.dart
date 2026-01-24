import 'dart:math' as math;
import 'package:flutter/material.dart';

enum OctagonAnchor {
  center,
  topEdge,
  topRightEdge,
  rightEdge,
  bottomRightEdge,
  bottomEdge,
  bottomLeftEdge,
  leftEdge,
  topLeftEdge,
  topRightVertex,
  bottomRightVertex,
  bottomLeftVertex,
  topLeftVertex,
}

class OctagonChild {
  final Widget child;
  final OctagonAnchor anchor;
  final Offset offset;

  OctagonChild({
    required this.child,
    this.anchor = OctagonAnchor.center,
    this.offset = Offset.zero,
  });
}

class OctagonLayout extends StatelessWidget {
  final List<OctagonChild> children;
  final double circumradius;
  final double scaleY;
  final double rotationDegrees;

  const OctagonLayout({
    super.key,
    required this.children,
    required this.circumradius,
    this.scaleY = 1.0,
    this.rotationDegrees = 22.5,
  });

  @override
  Widget build(BuildContext context) {
    final double apothem = circumradius * math.cos(math.pi / 8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: children.map((oc) {
            Offset anchorPos;

            Offset edgePos(double degrees) {
              final angle = degrees * math.pi / 180;
              return center +
                  Offset(
                    apothem * math.cos(angle),
                    apothem * math.sin(angle) * scaleY,
                  );
            }

            Offset vertexPos(double degrees) {
              final angle = degrees * math.pi / 180;
              return center +
                  Offset(
                    circumradius * math.cos(angle),
                    circumradius * math.sin(angle) * scaleY,
                  );
            }

            switch (oc.anchor) {
              case OctagonAnchor.center:
                anchorPos = center;
                break;
              // Edges (22.5 deg rotation assumed)
              case OctagonAnchor.rightEdge: // 0
                anchorPos = edgePos(0);
                break;
              case OctagonAnchor.bottomRightEdge: // 45
                anchorPos = edgePos(45);
                break;
              case OctagonAnchor.bottomEdge: // 90
                anchorPos = edgePos(90);
                break;
              case OctagonAnchor.bottomLeftEdge: // 135
                anchorPos = edgePos(135);
                break;
              case OctagonAnchor.leftEdge: // 180
                anchorPos = edgePos(180);
                break;
              case OctagonAnchor.topLeftEdge: // 225
                anchorPos = edgePos(225);
                break;
              case OctagonAnchor.topEdge: // 270
                anchorPos = edgePos(270);
                break;
              case OctagonAnchor.topRightEdge: // 315
                anchorPos = edgePos(315);
                break;

              // Vertices (Midpoints between edges in angled Octagon)
              // 0->45 Mid is 22.5? Wait, standard octagon vertices are at 22.5 + 45*n if rotated 22.5?
              // No, if edges are at 0, 45, 90 etc. (which means flat sides are facing Cardinals/Diagonals IF it was 8 sides.
              // Wait, math.cos(pi/8) implies 0 is Face center.
              // So vertices are at 22.5, 67.5, etc.
              case OctagonAnchor.bottomRightVertex: // 22.5 + 45 = 67.5
                anchorPos = vertexPos(67.5);
                break;
              case OctagonAnchor.bottomLeftVertex: // 112.5
                anchorPos = vertexPos(112.5);
                break;
              case OctagonAnchor.topLeftVertex: // 202.5
                anchorPos = vertexPos(202.5);
                break;
              case OctagonAnchor.topRightVertex: // 292.5 (-67.5)
                anchorPos = vertexPos(292.5);
                break;
            }

            return Positioned(
              left:
                  anchorPos.dx +
                  oc.offset.dx -
                  (oc.anchor == OctagonAnchor.center ? 0 : 0),
              // Note: Positioned works from Top/Left. We need to center the child at anchorPos.
              // Simplified for now: assume child handles its own center alignment or we shift by -width/2 -height/2?
              // Flutter Stack Positioned doesn't support center alignment easily without child size knowledge.
              // Legacy code seems to rely on child being wrapped or manually offset.
              // HexLayout usually centers children at the point.
              // Let's implement centering:
              top: anchorPos.dy + oc.offset.dy,
              child: Transform.translate(
                offset: const Offset(-0.5, -0.5), // Percentage? No.
                // We can use FractionalTranslation if we want to center the child on the point.
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: oc.child,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
