import 'package:flutter/material.dart';

class FogEffect extends StatelessWidget {
  final Widget child;
  final double padding;
  final Color color;
  final bool showTop;
  final bool showBottom;
  final bool showLeft;
  final bool showRight;
  final bool showSolidBase;

  static const double overlap = 0.1;
  static const double halfOverlap = overlap / 2;

  const FogEffect({
    super.key,
    required this.child,
    required this.padding,
    required this.color,
    this.showTop = true,
    this.showBottom = true,
    this.showLeft = true,
    this.showRight = true,
    this.showSolidBase = true,
  });

  @override
  Widget build(BuildContext context) {
    // Total offset from inward edge (when side is "foggy")
    final double inwardOffset = padding * 3.0;

    // Range of the actual gradient (transient part)
    final double fogRange = inwardOffset * 0.8;

    final leftPadding = showLeft ? inwardOffset : padding;
    final rightPadding = showRight ? inwardOffset : padding;
    final topPadding = showTop ? inwardOffset : padding;
    final bottomPadding = showBottom ? inwardOffset : padding;

    final transparentColor = color.withValues(alpha: 0.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Solid Background Base
        if (showSolidBase)
          Positioned.fill(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                showLeft ? fogRange : 0,
                showTop ? fogRange : 0,
                showRight ? fogRange : 0,
                showBottom ? fogRange : 0,
              ),
              color: color,
            ),
          ),

        // 2. Gradients
        if (showLeft)
          _FogGradient(
            alignment: Alignment.centerLeft,
            width: fogRange + overlap,
            colors: [transparentColor, color],
            left: -halfOverlap,
            top: showTop ? fogRange - halfOverlap : -halfOverlap,
            bottom: showBottom ? fogRange - halfOverlap : -halfOverlap,
          ),
        if (showRight)
          _FogGradient(
            alignment: Alignment.centerRight,
            width: fogRange + overlap,
            colors: [transparentColor, color],
            right: -halfOverlap,
            top: showTop ? fogRange - halfOverlap : -halfOverlap,
            bottom: showBottom ? fogRange - halfOverlap : -halfOverlap,
          ),
        if (showTop)
          _FogGradient(
            alignment: Alignment.topCenter,
            height: fogRange + overlap,
            colors: [transparentColor, color],
            top: -halfOverlap,
            left: showLeft ? fogRange - halfOverlap : -halfOverlap,
            right: showRight ? fogRange - halfOverlap : -halfOverlap,
          ),
        if (showBottom)
          _FogGradient(
            alignment: Alignment.bottomCenter,
            height: fogRange + overlap,
            colors: [transparentColor, color],
            bottom: -halfOverlap,
            left: showLeft ? fogRange - halfOverlap : -halfOverlap,
            right: showRight ? fogRange - halfOverlap : -halfOverlap,
          ),

        // 3. Corners
        if (showTop && showLeft)
          _FogRadial(
            center: Alignment.bottomRight,
            radius: 1.0,
            colors: [color, transparentColor],
            top: -halfOverlap,
            left: -halfOverlap,
            size: fogRange + overlap,
          ),
        if (showTop && showRight)
          _FogRadial(
            center: Alignment.bottomLeft,
            radius: 1.0,
            colors: [color, transparentColor],
            top: -halfOverlap,
            right: -halfOverlap,
            size: fogRange + overlap,
          ),
        if (showBottom && showLeft)
          _FogRadial(
            center: Alignment.topRight,
            radius: 1.0,
            colors: [color, transparentColor],
            bottom: -halfOverlap,
            left: -halfOverlap,
            size: fogRange + overlap,
          ),
        if (showBottom && showRight)
          _FogRadial(
            center: Alignment.topLeft,
            radius: 1.0,
            colors: [color, transparentColor],
            bottom: -halfOverlap,
            right: -halfOverlap,
            size: fogRange + overlap,
          ),

        // 4. Content
        Padding(
          padding: EdgeInsets.fromLTRB(
            leftPadding,
            topPadding,
            rightPadding,
            bottomPadding,
          ),
          child: child,
        ),
      ],
    );
  }
}

class _FogGradient extends StatelessWidget {
  final Alignment begin;
  final Alignment end;
  final double? width;
  final double? height;
  final List<Color> colors;
  final double? top, bottom, left, right;

  _FogGradient({
    required Alignment alignment,
    this.width,
    this.height,
    required this.colors,
    this.top,
    this.bottom,
    this.left,
    this.right,
  }) : begin = alignment,
       end = _opposite(alignment);

  static Alignment _opposite(Alignment a) {
    if (a == Alignment.centerLeft) return Alignment.centerRight;
    if (a == Alignment.centerRight) return Alignment.centerLeft;
    if (a == Alignment.topCenter) return Alignment.bottomCenter;
    if (a == Alignment.bottomCenter) return Alignment.topCenter;
    return a;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: begin, end: end, colors: colors),
        ),
      ),
    );
  }
}

class _FogRadial extends StatelessWidget {
  final Alignment center;
  final double radius;
  final List<Color> colors;
  final double? top, bottom, left, right;
  final double size;

  const _FogRadial({
    required this.center,
    required this.radius,
    required this.colors,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: center,
            radius: radius,
            colors: colors,
            stops: const [0.0, 1.0],
          ),
        ),
      ),
    );
  }
}
