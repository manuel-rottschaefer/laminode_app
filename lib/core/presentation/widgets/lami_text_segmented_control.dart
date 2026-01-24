import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';

class LamiTextSegmentedControl<T> extends StatelessWidget {
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool isCompact;

  const LamiTextSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LamiBox(
      padding: EdgeInsets.all(isCompact ? 2 : 4),
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.entries.map((entry) {
          final isSelected = entry.key == selected;
          return InkWell(
            onTap: () => onSelected(entry.key),
            borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                vertical: isCompact ? 4 : 8,
                horizontal: isCompact ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.surface
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(isCompact ? 4 : 6),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: isCompact ? 2 : 4,
                          offset: Offset(0, isCompact ? 1 : 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                widthFactor: 1.0, // Ensures it doesn't try to expand
                child: Text(
                  entry.value,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: isCompact ? 10 : null,
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
