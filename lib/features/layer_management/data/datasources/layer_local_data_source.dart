import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:laminode_app/features/layer_panel/data/models/layer_entry_model.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

abstract class LayerLocalDataSource {
  Future<void> saveLayer(LamiLayerEntry layer);
  Future<List<LamiLayerEntry>> getInstalledLayers();
}

class LayerLocalDataSourceImpl implements LayerLocalDataSource {
  Future<String> get _layersPath async {
    final appSupportDir = await getApplicationSupportDirectory();
    final path = p.join(appSupportDir.path, 'layers');
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return path;
  }

  @override
  Future<void> saveLayer(LamiLayerEntry layer) async {
    final path = await _layersPath;
    final file = File(p.join(path, '${layer.layerName}.lmdl'));
    final jsonString = jsonEncode(LayerEntryModel.fromEntity(layer).toJson());
    await file.writeAsString(jsonString);
  }

  @override
  Future<List<LamiLayerEntry>> getInstalledLayers() async {
    final path = await _layersPath;
    final directory = Directory(path);
    if (!await directory.exists()) return [];

    final files = directory.listSync().whereType<File>().where(
      (f) => f.path.endsWith('.lmdl'),
    );

    final List<LamiLayerEntry> layers = [];
    for (final file in files) {
      try {
        final jsonString = await file.readAsString();
        final json = jsonDecode(jsonString);
        layers.add(LayerEntryModel.fromJson(json).toEntity());
      } catch (_) {
        // Skip corrupted files
      }
    }
    return layers;
  }
}
