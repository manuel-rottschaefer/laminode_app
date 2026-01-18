import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/layer_panel/data/repositories/layer_panel_repository_impl.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/add_empty_layer.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/get_layers.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/remove_layer.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/update_layer_name.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

// Repository Provider
final layerPanelRepositoryProvider = Provider<LayerPanelRepository>((ref) {
  return LayerPanelRepositoryImpl();
});

// UseCase Providers
final getLayersUseCaseProvider = Provider((ref) {
  return GetLayersUseCase(ref.watch(layerPanelRepositoryProvider));
});

final addEmptyLayerUseCaseProvider = Provider((ref) {
  return AddEmptyLayerUseCase(ref.watch(layerPanelRepositoryProvider));
});

final removeLayerUseCaseProvider = Provider((ref) {
  return RemoveLayerUseCase(ref.watch(layerPanelRepositoryProvider));
});

final updateLayerNameUseCaseProvider = Provider((ref) {
  return UpdateLayerNameUseCase(ref.watch(layerPanelRepositoryProvider));
});

// Notifier
class LayerPanelNotifier extends StateNotifier<List<LamiLayerEntry>> {
  final GetLayersUseCase _getLayers;
  final AddEmptyLayerUseCase _addEmptyLayer;
  final RemoveLayerUseCase _removeLayer;
  final UpdateLayerNameUseCase _updateLayerName;

  LayerPanelNotifier({
    required GetLayersUseCase getLayers,
    required AddEmptyLayerUseCase addEmptyLayer,
    required RemoveLayerUseCase removeLayer,
    required UpdateLayerNameUseCase updateLayerName,
  }) : _getLayers = getLayers,
       _addEmptyLayer = addEmptyLayer,
       _removeLayer = removeLayer,
       _updateLayerName = updateLayerName,
       super([]) {
    _refresh();
  }

  void _refresh() {
    state = _getLayers();
  }

  void addEmptyLayer() {
    _addEmptyLayer();
    _refresh();
  }

  void removeLayer(int index) {
    _removeLayer(index);
    _refresh();
  }

  void updateLayerName(int index, String newName) {
    _updateLayerName(index, newName);
    _refresh();
  }
}

// State Provider
final layerPanelProvider =
    StateNotifierProvider<LayerPanelNotifier, List<LamiLayerEntry>>((ref) {
      return LayerPanelNotifier(
        getLayers: ref.watch(getLayersUseCaseProvider),
        addEmptyLayer: ref.watch(addEmptyLayerUseCaseProvider),
        removeLayer: ref.watch(removeLayerUseCaseProvider),
        updateLayerName: ref.watch(updateLayerNameUseCaseProvider),
      );
    });
