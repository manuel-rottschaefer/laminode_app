import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/evaluation/application/profile_evaluation_provider.dart';

class GraphNodeInputContainer extends ConsumerWidget {
  final CamParameter? parameter;
  final String? overrideValue;
  final Color borderColor;
  final bool isFocused;
  final GlobalKey? focusedKey;

  const GraphNodeInputContainer({
    super.key,
    this.parameter,
    this.overrideValue,
    required this.borderColor,
    this.isFocused = false,
    this.focusedKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (parameter == null) return const SizedBox.shrink();

    final paramName = parameter!.paramName;

    // Find the item in paramPanelItemsProvider to get the effective value
    final items = ref.watch(paramPanelItemsProvider);
    final item = items.firstWhere(
      (it) => it.param.paramName == paramName,
      orElse: () => ParamPanelItem(
        param: parameter as dynamic, // Fallback if not found
        state: ParamItemState.schema,
      ),
    );

    final selectedLayerIndex = ref.watch(
      paramPanelProvider.select((s) => s.selectedLayerIndices[paramName]),
    );
    final layers = ref.watch(layerPanelProvider.select((s) => s.layers));
    final isLayerLocked =
        selectedLayerIndex != null &&
        selectedLayerIndex < layers.length &&
        layers[selectedLayerIndex].isLocked;

    final isLocked =
        (ref.watch(
              paramPanelProvider.select((s) => s.lockedParams[paramName]),
            ) ??
            false) ||
        isLayerLocked;

    final evalResults = ref.watch(profileEvaluationProvider);
    final effectiveValue = evalResults[paramName];

    return Container(
      key: isFocused ? focusedKey : null,
      height: 32,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: isFocused ? 0.6 : 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isFocused
              ? borderColor
              : borderColor.withValues(alpha: isLocked ? 0.1 : 0.3),
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Opacity(
        opacity: isFocused ? 0.0 : 1.0,
        child: Text(
          _getDisplayValue(item.param, effectiveValue: effectiveValue),
          style: TextStyle(
            color: isLocked
                ? Colors.white38
                : (isFocused
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.85)),
            fontSize: 12,
            fontWeight: isFocused ? FontWeight.w700 : FontWeight.w500,
            fontFamily: 'monospace',
            letterSpacing: 0.4,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  String _getDisplayValue(CamParameter param, {dynamic effectiveValue}) {
    if (overrideValue != null) return overrideValue!;

    final dynamic value = effectiveValue ?? (param as dynamic).value;
    final valStr = (value ?? "").toString();

    if (param.quantity.quantityType == QuantityType.numeric) {
      if (valStr.isEmpty || valStr == 'null') return "0";
      return '$valStr ${param.quantity.quantitySymbol}';
    } else if (param.quantity.quantityType == QuantityType.boolean) {
      return valStr == 'true' ? 'Enabled' : 'Disabled';
    }
    return valStr;
  }
}
