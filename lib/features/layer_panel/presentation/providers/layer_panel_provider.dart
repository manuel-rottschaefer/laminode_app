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
class LayerPanelNotifier extends Notifier<List<LamiLayerEntry>> {
  @override
  List<LamiLayerEntry> build() {
    return ref.watch(getLayersUseCaseProvider)();
  }

  void _refresh() {
    state = ref.read(getLayersUseCaseProvider)();
  }

  void addEmptyLayer() {
    ref.read(addEmptyLayerUseCaseProvider)();
    _refresh();
  }

  void removeLayer(int index) {
    ref.read(removeLayerUseCaseProvider)(index);
    _refresh();
  }

  void updateLayerName(int index, String newName) {
    ref.read(updateLayerNameUseCaseProvider)(index, newName);
    _refresh();
  }
}

// State Provider
final layerPanelProvider =
    NotifierProvider<LayerPanelNotifier, List<LamiLayerEntry>>(
      () => LayerPanelNotifier(),
    );
