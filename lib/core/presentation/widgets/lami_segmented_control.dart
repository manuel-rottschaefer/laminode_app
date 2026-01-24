import 'package:flutter/material.dart';

class LamiSegment<T> {
  final T value;
  final IconData icon;
  final String tooltip;

  const LamiSegment({
    required this.value,
    required this.icon,
    required this.tooltip,
  });
}

class LamiSegmentedControl<T> extends StatelessWidget {
  final List<LamiSegment<T>> segments;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  const LamiSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: segments.map((segment) {
          final isSelected = segment.value == selectedValue;
          return Expanded(
            child: Tooltip(
              message: segment.tooltip,
              waitDuration: const Duration(milliseconds: 500),
              child: GestureDetector(
                onTap: () => onSelected(segment.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    segment.icon,
                    size: 16,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
