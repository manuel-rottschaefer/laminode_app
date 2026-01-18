import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

abstract class LayerPanelRepository {
  Future<LamiLayerEntry?> importLayer(String filePath);
  Future<void> exportLayer(LamiLayerEntry layer, String filePath);

  // Layer Management
  List<LamiLayerEntry> getLayers();
  void addLayer(LamiLayerEntry layer);
  void removeLayer(int index);
  void updateLayer(int index, LamiLayerEntry newLayer);
}
