import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';

class ParamLayerContribution {
  final String layerName;
  final String valueDisplay;
  final bool isBase;
  final bool isOverride;
  final bool isConstraint;

  const ParamLayerContribution({
    required this.layerName,
    required this.valueDisplay,
    this.isBase = false,
    this.isOverride = false,
    this.isConstraint = false,
  });
}

class ParamStackInfo {
  final String paramName;
  final List<ParamLayerContribution> contributions;

  const ParamStackInfo({required this.paramName, required this.contributions});
}

// ToDo: This should use the layer panel provider instead of re-implementing logic here.
final paramStackProvider = Provider.family<ParamStackInfo, String>((
  ref,
  paramName,
) {
  final contributions = <ParamLayerContribution>[];

  // 1. Get Base Data (Schema)
  final activeSchema = ref.watch(
    schemaShopProvider.select((s) => s.activeSchema),
  );
  if (activeSchema != null) {
    try {
      final paramDef = activeSchema.availableParameters.firstWhere(
        (p) => p.paramName == paramName,
      );

      // Calculate Default Value
      final defaultVal = paramDef.evalDefault();

      contributions.add(
        ParamLayerContribution(
          layerName: "Base Profile (Schema Default)",
          valueDisplay: defaultVal.toString(),
          isBase: true,
        ),
      );
    } catch (_) {
      // Param not found in schema?
    }
  }

  // 2. Get Layer Overrides
  final profile = ref.watch(
    profileManagerProvider.select((s) => s.currentProfile),
  );
  if (profile != null) {
    // Iterate layers from bottom (index 0?) to top.
    // Assuming profile.layers is ordered [BaseLayer, ..., TopLayer]
    // If layers are treated as a stack where last one overrides previous:

    for (final layer in profile.layers) {
      if (!layer.isActive) continue;

      // Better way to check existence:
      try {
        final entry = layer.parameters?.firstWhere(
          (p) => p.paramName == paramName,
        );
        if (entry != null && entry.isEdited) {
          contributions.add(
            ParamLayerContribution(
              layerName: layer.layerName,
              valueDisplay: entry.value.toString(),
              isOverride: true,
            ),
          );
        }
      } catch (_) {}
    }
  }

  // Reverse list? The user said "going up lists all the layers".
  // Usually stack is vizualized: Base at bottom, Overrides on top.
  // My list `contributions` starts with Base, then appends layers.
  // So `Column` in UI will render Base at top if I don't reverse or manage order.
  // User: "displays the schema-set thresholds below ... then going up lists all the layers"
  // This implies:
  // Top of Widget: Highest Layer (Final Value context)
  // ...
  // Middle: Layers
  // ...
  // Bottom: Schema/Base

  // So I should return them in order: Base -> Layer1 -> Layer2.
  // And the UI will render them: `...mockLayers.map` (Top to Bottom).

  // If "going up lists all layers" means "from bottom to top visually", then:
  // Bottom: Base
  // Top: Top Layer
  // Then `Column` children should be reversed? Or `contributions` should be reversed?

  // Let's implement providing Base -> Top. The UI can decide display order.

  return ParamStackInfo(paramName: paramName, contributions: contributions);
});
