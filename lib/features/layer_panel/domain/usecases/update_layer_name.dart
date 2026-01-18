import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class UpdateLayerNameUseCase {
  final LayerPanelRepository repository;

  UpdateLayerNameUseCase(this.repository);

  void call(int index, String newName) {
    final layers = repository.getLayers();
    if (index >= 0 && index < layers.length) {
      final oldLayer = layers[index];
      final updatedLayer = LamiLayerEntry(
        layerName: newName,
        parameters: oldLayer.parameters,
        layerAuthor: oldLayer.layerAuthor,
        layerDescription: oldLayer.layerDescription,
        isActive: oldLayer.isActive,
        isLocked: oldLayer.isLocked,
      );
      repository.updateLayer(index, updatedLayer);
    }
  }
}
