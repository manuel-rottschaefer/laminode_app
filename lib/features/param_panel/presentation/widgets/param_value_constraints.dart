import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class ParamValueConstraints extends StatelessWidget {
  const ParamValueConstraints({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CONSTRAINTS (THRESH)",
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Row(
          children: [
            const Expanded(
              child: _ConstraintItem(label: "MIN", value: "0.0"),
            ),
            const SizedBox(width: AppSpacing.s),
            const Expanded(
              child: _ConstraintItem(label: "MAX", value: "10.0"),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConstraintItem extends StatelessWidget {
  final String label;
  final String value;

  const _ConstraintItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9.0,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
