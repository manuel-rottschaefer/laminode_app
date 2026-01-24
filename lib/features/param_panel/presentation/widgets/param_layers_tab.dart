import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_stack_provider.dart';

class ParamLayersTab extends ConsumerWidget {
  final CamParamEntry param;

  const ParamLayersTab({super.key, required this.param});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stackInfo = ref.watch(paramStackProvider(param.paramName));

    // We want the stack order (Top Layer -> Base Layer)
    // contributions is built as [Base, Layer1, Layer2...]
    // So we invoke reversed.
    final layers = stackInfo.contributions.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s),
          child: Text(
            "COMPUTED STACK",
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (layers.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Text(
              "No configuration layers found.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...layers.map((l) => _buildLayerRow(context, l)),

        const SizedBox(height: AppSpacing.m),
        _buildFinalValue(context),
      ],
    );
  }

  Widget _buildLayerRow(BuildContext context, ParamLayerContribution layer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: layer.isOverride
            ? colorScheme.primaryContainer.withValues(alpha: 0.2)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: layer.isOverride
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            layer.isBase
                ? Icons.account_tree_outlined
                : layer.isConstraint
                ? Icons.gavel_rounded
                : Icons.layers_outlined,
            size: 14,
            color: layer.isOverride
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              layer.layerName,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: layer.isOverride
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          Text(
            // Append unit if it looks like a number and we have a unit
            "${layer.valueDisplay}${_shouldAppendUnit(layer.valueDisplay) ? ' ${param.quantity.quantitySymbol}' : ''}",
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              color: layer.isOverride
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldAppendUnit(String value) {
    // Simple heuristic: if value is numeric and unit is not empty
    if (param.quantity.quantitySymbol.isEmpty) return false;
    return double.tryParse(value) != null;
  }

  Widget _buildFinalValue(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LamiBox(
      padding: const EdgeInsets.all(AppSpacing.m),
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Final Computed Value",
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${param.value} ${param.quantity.quantitySymbol}",
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
