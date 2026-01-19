import "package:flutter/material.dart";

class LamiWindowButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isClose;

  const LamiWindowButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isClose = false,
  });

  @override
  State<LamiWindowButton> createState() => _LamiWindowButtonState();
}

class _LamiWindowButtonState extends State<LamiWindowButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color backgroundColor() {
      if (widget.isClose && isHovering) {
        return Colors.red;
      } else if (isHovering) {
        return colorScheme.outline.withValues(alpha: 0.5);
      } else {
        return Colors.transparent;
      }
    }

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovering = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip,
          child: Container(
            width: 40,
            height: 30,
            decoration: BoxDecoration(color: backgroundColor()),
            child: Icon(
              widget.icon,
              size: 16,
              color: widget.isClose && isHovering
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
