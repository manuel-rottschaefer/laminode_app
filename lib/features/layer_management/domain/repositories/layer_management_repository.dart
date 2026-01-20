import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

abstract class LayerManagementRepository {
  Future<LamiLayerEntry?> importLayer(String filePath);
  Future<void> exportLayer(LamiLayerEntry layer, String filePath);
  Future<void> saveLayerToStorage(LamiLayerEntry layer);
  Future<List<LamiLayerEntry>> getStoredLayers();
}
