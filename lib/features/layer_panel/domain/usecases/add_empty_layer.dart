import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class AddEmptyLayerUseCase {
  final LayerPanelRepository repository;

  AddEmptyLayerUseCase(this.repository);

  void call() {
    final emptyLayer = LamiLayerEntry(
      layerName: 'New Layer',
      parameters: [],
      layerAuthor: 'Unknown',
      layerDescription: 'Empty layer created manually',
    );
    repository.addLayer(emptyLayer);
  }
}
