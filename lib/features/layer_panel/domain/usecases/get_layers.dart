import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class GetLayersUseCase {
  final LayerPanelRepository repository;

  GetLayersUseCase(this.repository);

  List<LamiLayerEntry> call() {
    return repository.getLayers();
  }
}
