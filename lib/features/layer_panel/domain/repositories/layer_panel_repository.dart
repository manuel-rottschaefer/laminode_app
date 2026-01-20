import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

abstract class LayerPanelRepository {
  // Layer Stack Management
  List<LamiLayerEntry> getLayers();
  void setLayers(List<LamiLayerEntry> layers);
  void addLayer(LamiLayerEntry layer);
  void removeLayer(int index);
  void updateLayer(int index, LamiLayerEntry newLayer);
}
