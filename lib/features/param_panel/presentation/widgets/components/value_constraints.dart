import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class ValueConstraints extends StatelessWidget {
  const ValueConstraints({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(
              "No active constraints for this parameter.",
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
