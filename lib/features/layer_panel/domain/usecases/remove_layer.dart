import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class RemoveLayerUseCase {
  final LayerPanelRepository repository;

  RemoveLayerUseCase(this.repository);

  void call(int index) {
    repository.removeLayer(index);
  }
}
