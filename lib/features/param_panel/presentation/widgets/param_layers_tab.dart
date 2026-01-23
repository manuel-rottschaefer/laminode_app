import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';

class ParamLayersTab extends StatelessWidget {
  final CamParamEntry param;

  const ParamLayersTab({super.key, required this.param});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: In a real implementation, this data would come from a provider
    // that calculates the layer stack for this specific parameter.
    final mockLayers = [
      _LayerValue(name: "Base Profile", value: param.evalDefault().toString(), isBase: true),
      _LayerValue(name: "User Overrides", value: param.value.toString(), isOverride: param.isEdited),
      _LayerValue(name: "Machine Limits", value: "Max: 100", isConstraint: true),
    ];

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
        ...mockLayers.map((l) => _buildLayerRow(context, l)),
        const SizedBox(height: AppSpacing.m),
        _buildFinalValue(context),
      ],
    );
  }

  Widget _buildLayerRow(BuildContext context, _LayerValue layer) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
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
            color: layer.isOverride ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              layer.name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 11,
                fontWeight: layer.isOverride ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            layer.value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              color: layer.isOverride ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
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
          Text("Final Computed Value", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
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

class _LayerValue {
  final String name;
  final String value;
  final bool isBase;
  final bool isOverride;
  final bool isConstraint;

  _LayerValue({
    required this.name,
    required this.value,
    this.isBase = false,
    this.isOverride = false,
    this.isConstraint = false,
  });
}
