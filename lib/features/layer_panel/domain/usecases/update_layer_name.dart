import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class UpdateLayerNameUseCase {
  final LayerPanelRepository repository;

  UpdateLayerNameUseCase(this.repository);

  void call(int index, String newName) {
    final layers = repository.getLayers();
    if (index >= 0 && index < layers.length) {
      final updatedLayer = layers[index].copyWith(layerName: newName);
      repository.updateLayer(index, updatedLayer);
    }
  }
}
