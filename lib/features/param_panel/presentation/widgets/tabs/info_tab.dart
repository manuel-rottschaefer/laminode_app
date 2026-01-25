import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/presentation/widgets/lami_colored_badge.dart';
import 'package:laminode_app/core/theme/app_colors.dart';

class InfoTab extends StatelessWidget {
  final CamParamEntry param;
  final String? description;

  const InfoTab({super.key, required this.param, this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = LamiColor.fromString(
      param.category.categoryColorName,
    ).value;

    final bool isLongName = param.paramName.length > 15;

    return LamiBox(
      backgroundColor: colorScheme.surface,
      borderColor: categoryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  param.paramName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: isLongName ? 10 : 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              LamiColoredBadge(
                color: Colors.grey.withValues(alpha: 0.5),
                label: param.quantity.quantityType.name.toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            description ??
                param.paramDescription ??
                "No description available.",
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
              fontSize: 11,
            ),
          ),
          if (param.baseParam != null) ...[
            const SizedBox(height: AppSpacing.m),
            _InfoRow(
              label: "BASE",
              value: param.baseParam!,
              isMonospace: true,
              valueFontSize: 10,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;
  final double? valueFontSize;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
    this.valueFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontSize: 8,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontFamily: isMonospace ? 'monospace' : null,
              fontWeight: FontWeight.w500,
              fontSize: valueFontSize ?? 11,
            ),
          ),
        ),
      ],
    );
  }
}
