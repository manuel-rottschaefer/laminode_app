import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class AddLayerUseCase {
  final LayerPanelRepository repository;

  AddLayerUseCase(this.repository);

  void call({
    required String name,
    required String description,
    required String category,
  }) {
    final newLayer = LamiLayerEntry(
      layerName: name,
      layerDescription: description,
      layerCategory: category,
      layerAuthor: 'User', // Default author for now
      parameters: [],
    );
    repository.addLayer(newLayer);
  }
}
