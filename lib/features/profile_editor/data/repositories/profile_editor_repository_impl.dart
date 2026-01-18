import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:laminode_app/core/domain/entities/lami_layer.dart';
import 'package:laminode_app/core/domain/entities/lami_profile.dart';
import 'package:laminode_app/features/layer_panel/data/models/layer_entry_model.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/profile_editor/data/models/profile_model.dart';
import 'package:laminode_app/features/profile_editor/domain/repositories/profile_editor_repository.dart';

class ProfileEditorRepositoryImpl implements ProfileEditorRepository {
  @override
  Future<void> exportProfile(LamiProfile profile, String filePath) async {
    final archive = Archive();

    // Add profile.json (currently empty)
    final profileJson = jsonEncode({});
    archive.addFile(
      ArchiveFile('profile.json', profileJson.length, utf8.encode(profileJson)),
    );

    // Add layers
    for (int i = 0; i < profile.layers.length; i++) {
      final layer = profile.layers[i];
      if (layer is LamiLayerEntry) {
        final layerModel = LayerEntryModel(
          layerName: layer.layerName,
          parameters: layer.parameters,
          layerAuthor: layer.layerAuthor,
          layerDescription: layer.layerDescription,
          isActive: layer.isActive,
          isLocked: layer.isLocked,
        );
        final layerJson = jsonEncode(layerModel.toJson());
        final fileName = 'layers/layer_$i.lmdl';
        archive.addFile(
          ArchiveFile(fileName, layerJson.length, utf8.encode(layerJson)),
        );
      }
    }

    final zipEncoder = ZipEncoder();
    final encodedZip = zipEncoder.encode(archive);

    final file = File(filePath);
    await file.writeAsBytes(encodedZip);
  }

  @override
  Future<LamiProfile?> importProfile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Read profile.json (currently empty, but we'll try to find it)
    String profileName = 'Imported Profile';
    final profileFile = archive.findFile('profile.json');
    if (profileFile != null) {
      // Logic for reading profile.json if it wasn't empty
    }

    final layers = <LamiLayer>[];
    for (final file in archive) {
      if (file.isFile &&
          file.name.startsWith('layers/') &&
          file.name.endsWith('.lmdl')) {
        final layerJson = utf8.decode(file.content as List<int>);
        final layerMap = jsonDecode(layerJson) as Map<String, dynamic>;
        layers.add(LayerEntryModel.fromJson(layerMap));
      }
    }

    return ProfileModel(profileName: profileName, layers: layers);
  }
}
