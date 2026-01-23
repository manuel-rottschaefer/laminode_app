import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/presentation/widgets/lami_colored_badge.dart';

class ParamInfo extends StatelessWidget {
  final CamParamEntry param;
  final String? description;

  const ParamInfo({super.key, required this.param, this.description});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
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
                  color: theme.colorScheme.onSurface,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                  fontSize: 10.5,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            LamiColoredBadge(
              color: LamiColors.registry[param.category.categoryColorName] ?? Colors.grey,
              label: param.category.categoryTitle.toUpperCase(),
            ),
          ],
        ),
        if (param.baseParam != null) ...[
          const SizedBox(height: AppSpacing.s),
          _InfoRow(label: "INHERITS\nFROM", value: param.baseParam!, isMonospace: true, valueFontSize: 10),
        ],
        const SizedBox(height: AppSpacing.m),
        _InfoRow(
          label: "QUANTITY\nTYPE",
          value: param.quantity.quantityType.name.toUpperCase(),
          isMonospace: true,
          valueFontSize: 10,
        ),
        const SizedBox(height: AppSpacing.m),
        Text(
          "\"${description ?? param.paramDescription ?? "No description available for this parameter."}\"",
          textAlign: TextAlign.justify,
          style: textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.4,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;
  final double? valueFontSize;

  const _InfoRow({required this.label, required this.value, this.isMonospace = false, this.valueFontSize});

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
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 8,
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontFamily: isMonospace ? 'monospace' : null,
              fontWeight: isMonospace ? FontWeight.w500 : null,
              fontSize: valueFontSize ?? 11,
            ),
          ),
        ),
      ],
    );
  }
}
