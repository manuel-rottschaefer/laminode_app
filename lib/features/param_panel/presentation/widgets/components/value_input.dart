import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_input.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';

class ValueInput extends ConsumerWidget {
  final ParamPanelItem item;
  final TextEditingController controller;

  const ValueInput({super.key, required this.item, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedLayerIndex = ref.watch(
      paramPanelProvider.select(
        (s) => s.selectedLayerIndices[item.param.paramName],
      ),
    );
    final layers = ref.watch(layerPanelProvider.select((s) => s.layers));
    final isLayerLocked =
        selectedLayerIndex != null &&
        selectedLayerIndex < layers.length &&
        layers[selectedLayerIndex].isLocked;

    final isLocked = item.param.isLocked || isLayerLocked;

    return Row(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              LamiInput(
                label: 'Value',
                controller: controller,
                enabled: !isLocked,
                isMonospace: true,
                onChanged: (value) {
                  ref
                      .read(paramPanelProvider.notifier)
                      .updateParamValue(item.param.paramName, value);
                },
              ),
              if (item.param.quantity.quantitySymbol.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    item.param.quantity.quantitySymbol,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        LamiIcon(
          icon: isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
          size: 18,
          padding: 8,
          onPressed: () {
            ref
                .read(paramPanelProvider.notifier)
                .toggleLock(item.param.paramName);
          },
          color: isLocked
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        LamiIcon(
          icon: Icons.restart_alt_rounded,
          size: 18,
          padding: 8,
          onPressed: isLocked
              ? null
              : () {
                  ref
                      .read(paramPanelProvider.notifier)
                      .resetParamValue(item.param.paramName);
                },
          color: isLocked
              ? colorScheme.onSurface.withValues(alpha: 0.1)
              : colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}
