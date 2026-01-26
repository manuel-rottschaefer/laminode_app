import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_stack_info.dart';

class GetParamStackUseCase {
  ParamStackInfo execute({
    required String paramName,
    required List<LamiLayerEntry> layers,
    required CamSchemaEntry? activeSchema,
  }) {
    final contributions = <ParamLayerContribution>[];

    // 1. Get Base Data (Schema)
    if (activeSchema != null) {
      try {
        final paramDef = activeSchema.availableParameters.firstWhere(
          (p) => p.paramName == paramName,
        );

        // Calculate Default Value
        final defaultVal = paramDef.evalDefault();

        contributions.add(
          ParamLayerContribution(
            layerName: "Base Layer",
            valueDisplay: defaultVal.toString(),
            isBase: true,
          ),
        );
      } catch (_) {
        // Param not found in schema?
      }
    }

    // 2. Get Layer Overrides
    // We iterate reversed because in the layer list (from top to bottom),
    // the top-most layer is index 0. We want index 0 to be added LAST
    // in the contribution stack so it correctly overrides previous layers.
    for (final layer in layers.reversed) {
      if (!layer.isActive) continue;

      try {
        final entry = layer.parameters?.firstWhere(
          (p) => p.paramName == paramName,
        );
        if (entry != null && entry.isEdited) {
          contributions.add(
            ParamLayerContribution(
              layerName: layer.layerName,
              valueDisplay: entry.value.toString(),
              layerCategory: layer.layerCategory,
              isOverride: true,
            ),
          );
        }
      } catch (_) {}
    }

    return ParamStackInfo(paramName: paramName, contributions: contributions);
  }
}
