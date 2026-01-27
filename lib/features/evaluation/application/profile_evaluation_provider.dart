import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/evaluation/application/providers.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';

/// Provides a map of parameter names to their fully evaluated (effective) values.
final profileEvaluationProvider = Provider<Map<String, dynamic>>((ref) {
  final activeSchema = ref.watch(
    schemaShopProvider.select((s) => s.activeSchema),
  );
  final layers = ref.watch(layerPanelProvider.select((s) => s.layers));
  final paramPanelState = ref.watch(paramPanelProvider);
  final engine = ref.watch(evaluationEngineProvider);

  if (activeSchema == null) return const {};

  final Map<String, CamParamEntry> effectiveParams = {};

  // 1. Start with schema defaults (though we'll overwrite them)
  for (final p in activeSchema.availableParameters) {
    effectiveParams[p.paramName] = p;
  }

  // 2. Overwrite with layer-specific values if applicable
  // For simplicity, we use the selected layer for each param from paramPanelState
  for (final paramName in effectiveParams.keys) {
    final selectedIndex = paramPanelState.selectedLayerIndices[paramName];
    if (selectedIndex != null &&
        selectedIndex >= 0 &&
        selectedIndex < layers.length) {
      final layer = layers[selectedIndex];
      final layerParam = layer.parameters?.cast<CamParamEntry?>().firstWhere(
        (p) => p?.paramName == paramName,
        orElse: () => null,
      );
      if (layerParam != null) {
        effectiveParams[paramName] = layerParam;
      }
    }
  }

  // 3. Resolve evaluation context
  final Map<String, dynamic> context = {};
  final List<CamParamEntry> needsEvaluation = [];

  for (final p in effectiveParams.values) {
    // If it has a concrete value (edited or schema-provided concrete value)
    // AND it's not "empty" (null or empty string for numeric)
    if (_hasConcreteValue(p)) {
      context[p.paramName] = p.value;
    } else {
      needsEvaluation.add(p);
    }
  }

  // 4. Iteratively evaluate defaults
  // We do multiple passes to handle dependencies (e.g., A = B + 1, B = 10)
  bool changed;
  int passes = 0;
  const maxPasses = 10; // Safety limit

  do {
    changed = false;
    passes++;

    final iterator = needsEvaluation.iterator;
    final stillNeedsEval = <CamParamEntry>[];

    while (iterator.moveNext()) {
      final p = iterator.current;
      if (p.defaultValue.isEmpty) {
        context[p.paramName] = p.quantity.fallbackValue;
        changed = true;
        continue;
      }

      try {
        final result = engine.evaluate(p.defaultValue.expression, context);
        if (result != null) {
          context[p.paramName] = result;
          changed = true;
        } else {
          stillNeedsEval.add(p);
        }
      } catch (_) {
        // Dependencies might not be resolved yet
        stillNeedsEval.add(p);
      }
    }

    needsEvaluation.clear();
    needsEvaluation.addAll(stillNeedsEval);
  } while (changed && needsEvaluation.isNotEmpty && passes < maxPasses);

  // 5. Fill remaining with fallback
  for (final p in needsEvaluation) {
    context[p.paramName] = p.quantity.fallbackValue;
  }

  return context;
});

bool _hasConcreteValue(CamParamEntry p) {
  if (p.value == null) return false;
  if (p.quantity.quantityType == QuantityType.numeric) {
    if (p.value is String && (p.value as String).isEmpty) return false;
  }
  // If isEdited is true, we always treat it as a concrete value even if it's 0 or false
  return p.isEdited;
}
