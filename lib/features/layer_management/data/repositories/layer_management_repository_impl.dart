import 'dart:convert';
import 'dart:io';
import 'package:laminode_app/features/layer_management/data/datasources/layer_local_data_source.dart';
import 'package:laminode_app/features/layer_management/domain/repositories/layer_management_repository.dart';
import 'package:laminode_app/features/layer_panel/data/models/layer_entry_model.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

class LayerManagementRepositoryImpl implements LayerManagementRepository {
  final LayerLocalDataSource _localDataSource;

  LayerManagementRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveLayerToStorage(LamiLayerEntry layer) async {
    await _localDataSource.saveLayer(layer);
  }

  @override
  Future<List<LamiLayerEntry>> getStoredLayers() async {
    return await _localDataSource.getInstalledLayers();
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
    final layer = LayerEntryModel.fromJson(jsonMap).toEntity();
    await saveLayerToStorage(layer);
    return layer;
  }
}
