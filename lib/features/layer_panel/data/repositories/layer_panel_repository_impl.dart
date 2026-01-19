import 'dart:convert';
import 'dart:io';
import 'package:laminode_app/features/layer_panel/data/models/layer_entry_model.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class LayerPanelRepositoryImpl implements LayerPanelRepository {
  final List<LamiLayerEntry> _hostedLayers = [];

  @override
  List<LamiLayerEntry> getLayers() => List.unmodifiable(_hostedLayers);

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

  @override
  Future<void> exportLayer(LamiLayerEntry layer, String filePath) async {
    final model = LayerEntryModel.fromEntity(layer);
    final jsonString = jsonEncode(model.toJson());
    final file = File(filePath);
    await file.writeAsString(jsonString);
  }

  @override
  Future<LamiLayerEntry?> importLayer(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return LayerEntryModel.fromJson(jsonMap).toEntity();
  }
}
