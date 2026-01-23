import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class ParamRelationTab extends StatelessWidget {
  final CamParamEntry param;

  const ParamRelationTab({super.key, required this.param});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasRelations =
        param.defaultValue != null || param.suggestValue != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (param.defaultValue != null) ...[
          _buildRelationItem(
            context,
            label: "Default Value Formula",
            expression: param.defaultValue!.expression ?? '',
            icon: Icons.functions_rounded,
          ),
        ],
        if (param.suggestValue != null) ...[
          if (param.defaultValue != null) const SizedBox(height: AppSpacing.m),
          _buildRelationItem(
            context,
            label: "Suggested Value Formula",
            expression: param.suggestValue!.expression ?? '',
            icon: Icons.tips_and_updates_outlined,
          ),
        ],
        if (!hasRelations)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(
              child: Text(
                "No computational relations defined",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRelationItem(
    BuildContext context, {
    required String label,
    required String expression,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LamiBox(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.m),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              expression.isEmpty ? "(empty)" : expression,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
