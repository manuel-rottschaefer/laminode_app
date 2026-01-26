import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_stack_provider.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_stack_info.dart';

class LayersTab extends ConsumerWidget {
  final CamParamEntry param;

  const LayersTab({super.key, required this.param});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = LamiColor.fromString(
      param.category.categoryColorName,
    ).value;
    final stackInfo = ref.watch(paramStackProvider(param.paramName));

    final layers = stackInfo.contributions.reversed.toList();

    return LamiBox(
      backgroundColor: colorScheme.surface,
      borderColor: categoryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
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
            ...layers.indexed.map(
              (entry) =>
                  _buildLayerRow(context, entry.$2, isTop: entry.$1 == 0),
            ),
        ],
      ),
    );
  }

  Widget _buildLayerRow(
    BuildContext context,
    ParamLayerContribution layer, {
    bool isTop = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final layerColor = _getLayerColor(layer);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: layer.isOverride
            ? layerColor.withValues(alpha: isTop ? 0.1 : 0.05)
            : colorScheme.surfaceContainerHighest.withValues(
                alpha: isTop ? 0.2 : 0.1,
              ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: layer.isOverride
              ? layerColor.withValues(alpha: isTop ? 0.3 : 0.15)
              : colorScheme.outlineVariant.withValues(alpha: isTop ? 0.2 : 0.1),
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
                ? layerColor.withValues(alpha: isTop ? 1.0 : 0.6)
                : colorScheme.onSurfaceVariant.withValues(
                    alpha: isTop ? 1.0 : 0.6,
                  ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Row(
              children: [
                Text(
                  layer.layerName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                    color: isTop
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            layer.valueDisplay,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
              color: isTop
                  ? (layer.isOverride
                        ? colorScheme.primary
                        : colorScheme.onSurface)
                  : (layer.isOverride
                        ? colorScheme.primary.withValues(alpha: 0.6)
                        : colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            ),
          ),
          if (_shouldAppendUnit(layer.valueDisplay)) ...[
            const SizedBox(width: 4),
            Text(
              param.quantity.quantitySymbol,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 9,
                fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                color: isTop
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getLayerColor(ParamLayerContribution layer) {
    if (layer.layerCategory == null) {
      return LamiColor.fromString(param.category.categoryColorName).value;
    }

    // Try to get color from layerCategory string
    final color = LamiColor.fromString(layer.layerCategory);

    // If it's blue (default), it might be because layerCategory is a category name like 'extrusion'
    // not a color name. In that case, we should probably still use the param's category color
    // but the LamiColor.fromString doesn't know about category -> color mappings.
    // However, if the result is blue and layerCategory is NOT 'blue', we fallback.
    if (color == LamiColor.blue &&
        layer.layerCategory!.toLowerCase() != 'blue') {
      return LamiColor.fromString(param.category.categoryColorName).value;
    }

    return color.value;
  }

  bool _shouldAppendUnit(String value) {
    if (param.quantity.quantitySymbol.isEmpty) return false;
    return double.tryParse(value) != null;
  }
}
