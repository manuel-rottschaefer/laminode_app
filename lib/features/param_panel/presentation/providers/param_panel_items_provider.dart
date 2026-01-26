import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'param_panel_provider.dart';

final paramPanelItemsProvider = Provider<List<ParamPanelItem>>((ref) {
  final state = ref.watch(paramPanelProvider);
  final activeSchema = ref.watch(
    schemaShopProvider.select((s) => s.activeSchema),
  );
  final layers = ref.watch(layerPanelProvider.select((s) => s.layers));

  if (activeSchema == null) return const [];

  final normalizedQuery = state.searchQuery.toLowerCase();
  final List<ParamPanelItem> filteredItems = [];

  for (final paramDef in activeSchema.availableParameters) {
    final matchesSearch =
        normalizedQuery.isNotEmpty &&
        (paramDef.paramName.toLowerCase().contains(normalizedQuery) ||
            paramDef.paramTitle.toLowerCase().contains(normalizedQuery));

    if (normalizedQuery.isNotEmpty &&
        !matchesSearch &&
        state.focusedParamName == null) {
      continue;
    }

    if (state.focusedParamName != null &&
        paramDef.paramName != state.focusedParamName) {
      continue;
    }

    // Merge layer value
    CamParamEntry param = paramDef;
    final selectedIndex = state.selectedLayerIndices[paramDef.paramName];

    if (selectedIndex != null &&
        selectedIndex >= 0 &&
        selectedIndex < layers.length) {
      final layer = layers[selectedIndex];
      try {
        final layerParam = layer.parameters?.firstWhere(
          (p) => p.paramName == paramDef.paramName,
        );
        if (layerParam != null) {
          param = layerParam;
        }
      } catch (_) {
        // Param not edited in this layer yet, use schema def as base
      }
    }

    // Apply lock from state
    if (state.lockedParams[param.paramName] ?? false) {
      param = param.copyWith(isLocked: true);
    }

    final itemState = state.focusedParamName != null
        ? ParamItemState.reference
        : (normalizedQuery.isNotEmpty
              ? ParamItemState.search
              : ParamItemState.schema);

    filteredItems.add(ParamPanelItem(param: param, state: itemState));
  }
  return filteredItems;
});
