import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class LayerPanelRepositoryImpl implements LayerPanelRepository {
  final List<LamiLayerEntry> _hostedLayers = [];

  LayerPanelRepositoryImpl();

  @override
  List<LamiLayerEntry> getLayers() => List.unmodifiable(_hostedLayers);

  @override
  void setLayers(List<LamiLayerEntry> layers) {
    _hostedLayers.clear();
    _hostedLayers.addAll(layers);
  }

  @override
  void addLayer(LamiLayerEntry layer) {
    _hostedLayers.add(layer);
  }

  @override
  void removeLayer(int index) {
    if (index >= 0 && index < _hostedLayers.length) {
      _hostedLayers.removeAt(index);
    }
  }

  @override
  void updateLayer(int index, LamiLayerEntry newLayer) {
    if (index >= 0 && index < _hostedLayers.length) {
      _hostedLayers[index] = newLayer;
    }
  }
}
