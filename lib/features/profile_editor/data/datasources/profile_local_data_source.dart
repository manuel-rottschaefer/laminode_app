import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:laminode_app/features/layer_panel/data/models/layer_entry_model.dart';
import 'package:laminode_app/features/profile_editor/data/models/profile_model.dart';

abstract class ProfileLocalDataSource {
  Future<ProfileModel?> readProfileFromZip(String filePath);
  Future<void> writeProfileToZip(ProfileModel profile, String filePath);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  @override
  Future<void> writeProfileToZip(ProfileModel profile, String filePath) async {
    final archive = Archive();

    // Add profile.json
    final profileJson = jsonEncode(profile.toJson());
    archive.addFile(
      ArchiveFile('profile.json', profileJson.length, utf8.encode(profileJson)),
    );

    // Add layers
    for (int i = 0; i < profile.layers.length; i++) {
      final layer = profile.layers[i];
      final layerModel = LayerEntryModel.fromEntity(layer);
      final layerJson = jsonEncode(layerModel.toJson());
      final fileName = 'layers/layer_$i.lmdl';
      archive.addFile(
        ArchiveFile(fileName, layerJson.length, utf8.encode(layerJson)),
      );
    }

    final zipEncoder = ZipEncoder();
    final encodedZip = zipEncoder.encode(archive);

    final file = File(filePath);
    await file.writeAsBytes(encodedZip);
  }

  @override
  Future<ProfileModel?> readProfileFromZip(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    String profileName = 'Imported Profile';
    final profileFile = archive.findFile('profile.json');
    if (profileFile != null) {
      final content = utf8.decode(profileFile.content as List<int>);
      final json = jsonDecode(content) as Map<String, dynamic>;
      profileName = json['profileName'] ?? 'Imported Profile';
    }

    final layers = <LayerEntryModel>[];
    for (final file in archive) {
      if (file.isFile &&
          file.name.startsWith('layers/') &&
          file.name.endsWith('.lmdl')) {
        final layerJson = utf8.decode(file.content as List<int>);
        final layerMap = jsonDecode(layerJson) as Map<String, dynamic>;
        layers.add(LayerEntryModel.fromJson(layerMap));
      }
    }

    return ProfileModel(
      profileName: profileName,
      layers: layers.map((e) => e.toEntity()).toList(),
    );
  }
}
