import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/layer_management/presentation/providers/layer_management_provider.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';

import 'layer_panel_state.dart';
import 'layer_panel_use_cases.dart';

export 'layer_panel_state.dart';
export 'layer_panel_use_cases.dart';

// Notifier
class LayerPanelNotifier extends Notifier<LayerPanelState> {
  @override
  LayerPanelState build() {
    return LayerPanelState(layers: ref.read(getLayersUseCaseProvider)());
  }

  void setLayers(List<LamiLayerEntry> layers) {
    ref.read(layerPanelRepositoryProvider).setLayers(layers);
    state = state.copyWith(layers: layers);
  }

  void _refresh() {
    final newLayers = ref.read(getLayersUseCaseProvider)();
    state = state.copyWith(layers: newLayers);

    // Save to profile
    ref.read(profileManagerProvider.notifier).updateLayers(newLayers);
  }

  void setExpandedIndex(int? index) {
    if (state.expandedIndex == index) {
      state = state.copyWith(clearExpanded: true);
    } else {
      state = state.copyWith(expandedIndex: index);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void reorderLayers(int oldIndex, int newIndex) {
    final layers = List<LamiLayerEntry>.from(state.layers);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = layers.removeAt(oldIndex);
    layers.insert(newIndex, item);

    final repo = ref.read(layerPanelRepositoryProvider);
    repo.setLayers(layers);

    // Adjust expanded index if it was moving
    int? newExpanded = state.expandedIndex;
    if (state.expandedIndex == oldIndex) {
      newExpanded = newIndex;
    } else if (state.expandedIndex != null) {
      // Logic for shifting... maybe it's easier to just close it or handle it carefully
      // ReorderableListView handles most things, but we need to track our index.
    }

    _refresh();
    state = state.copyWith(expandedIndex: newExpanded);
  }

  void moveLayerUp(int index) {
    if (index > 0) {
      reorderLayers(index, index - 1);
    }
  }

  void moveLayerDown(int index) {
    if (index < state.layers.length - 1) {
      reorderLayers(index, index + 2);
    }
  }

  void addLayer({
    required String name,
    String description = "",
    required String category,
  }) {
    ref.read(addLayerUseCaseProvider)(
      name: name,
      description: description,
      category: category,
    );
    _refresh();
  }

  void removeLayer(int index) {
    ref.read(removeLayerUseCaseProvider)(index);
    if (state.expandedIndex == index) {
      state = state.copyWith(clearExpanded: true);
    } else if (state.expandedIndex != null && state.expandedIndex! > index) {
      state = state.copyWith(expandedIndex: state.expandedIndex! - 1);
    }
    _refresh();
  }

  void toggleLayerActive(int index) {
    final layers = state.layers;
    if (index >= 0 && index < layers.length) {
      final updatedLayer = layers[index].copyWith(
        isActive: !layers[index].isActive,
      );
      ref.read(layerPanelRepositoryProvider).updateLayer(index, updatedLayer);
      _refresh();
    }
  }

  void toggleLayerLocked(int index) {
    final layers = state.layers;
    if (index >= 0 && index < layers.length) {
      final updatedLayer = layers[index].copyWith(
        isLocked: !layers[index].isLocked,
      );
      ref.read(layerPanelRepositoryProvider).updateLayer(index, updatedLayer);
      _refresh();
    }
  }

  void updateLayer(int index, {String? name, String? description}) {
    final layers = state.layers;
    if (index >= 0 && index < layers.length) {
      final updatedLayer = layers[index].copyWith(
        layerName: name ?? layers[index].layerName,
        layerDescription: description ?? layers[index].layerDescription,
      );
      ref.read(layerPanelRepositoryProvider).updateLayer(index, updatedLayer);
      ref
          .read(layerManagementRepositoryProvider)
          .saveLayerToStorage(updatedLayer);
      _refresh();
    }
  }

  void updateParamValue(int layerIndex, String paramName, dynamic value) {
    final layers = state.layers;
    if (layerIndex >= 0 && layerIndex < layers.length) {
      final layer = layers[layerIndex];
      final parameters = List<CamParamEntry>.from(layer.parameters ?? []);

      final paramIndex = parameters.indexWhere((p) => p.paramName == paramName);
      if (paramIndex != -1) {
        parameters[paramIndex] = parameters[paramIndex].copyWith(
          value: value,
          isEdited: true,
        );
      } else {
        // If not found in layer, we might want to add it from schema?
        // But for now, let's assume it should be there if we are editing it.
        // Actually, if it's not edited, it might not be in the layer's parameters list.
        // We need to fetch the base definition from schema if we want to add it.
        final activeSchema = ref.read(schemaShopProvider).activeSchema;
        if (activeSchema != null) {
          try {
            final schemaParam = activeSchema.availableParameters.firstWhere(
              (p) => p.paramName == paramName,
            );
            parameters.add(schemaParam.copyWith(value: value, isEdited: true));
          } catch (_) {}
        }
      }

      final updatedLayer = layer.copyWith(parameters: parameters);
      ref
          .read(layerPanelRepositoryProvider)
          .updateLayer(layerIndex, updatedLayer);
      _refresh();
    }
  }

  void resetParamValue(int layerIndex, String paramName) {
    final layers = state.layers;
    if (layerIndex >= 0 && layerIndex < layers.length) {
      final layer = layers[layerIndex];
      final parameters = List<CamParamEntry>.from(layer.parameters ?? []);

      parameters.removeWhere((p) => p.paramName == paramName);

      final updatedLayer = layer.copyWith(parameters: parameters);
      ref
          .read(layerPanelRepositoryProvider)
          .updateLayer(layerIndex, updatedLayer);
      _refresh();
    }
  }
}

// State Provider
final layerPanelProvider =
    NotifierProvider<LayerPanelNotifier, LayerPanelState>(
      () => LayerPanelNotifier(),
    );
