import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

mixin ManualSchemaLocalDataSourceMixin {
  Future<String> get pluginsPath async {
    final appSupportDir = await getApplicationSupportDirectory();
    return p.join(appSupportDir.path, 'plugins');
  }

  Future<bool> applicationExistsImpl(String appName) async {
    final appSupportDir = await getApplicationSupportDirectory();
    final appPath = p.join(
      appSupportDir.path,
      'applications',
      appName.replaceAll(' ', '_'),
    );
    return await Directory(appPath).exists();
  }

  Future<void> saveManualSchemaImpl(
    String appName,
    String schemaId,
    Map<String, dynamic> schemaJson,
    String? adapterCode,
  ) async {
    final rootPath = await pluginsPath;
    final pluginId = "manual_${appName.replaceAll(' ', '_').toLowerCase()}";
    final pluginPath = p.join(rootPath, pluginId);

    final pluginDir = Directory(pluginPath);
    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
    }

    if (adapterCode != null) {
      final adapterFile = File(p.join(pluginPath, 'adapter.js'));
      await adapterFile.writeAsString(adapterCode);
    }

    final manifestFile = File(p.join(pluginPath, 'manifest.json'));
    Map<String, dynamic> manifest;

    if (await manifestFile.exists()) {
      manifest = jsonDecode(await manifestFile.readAsString());
      final List schemas = manifest['schemas'];
      if (!schemas.any((s) => s['id'] == schemaId)) {
        schemas.add({
          'id': schemaId,
          'version': schemaId.startsWith('v')
              ? schemaId.substring(1)
              : schemaId,
          'releaseDate': DateTime.now().toIso8601String().split('T')[0],
        });
      }
    } else {
      manifest = {
        'pluginType': 'application',
        'displayName': '$appName (Local)',
        'description': 'Manually uploaded schemas for $appName',
        'application': {
          'appName': appName,
          'appVersion': 'Local',
          'vendor': 'Unknown',
          'website': '',
          'sector': schemaJson['manifest']?['targetAppSector'] ?? 'FDM',
        },
        'plugin': {
          'pluginID': pluginId,
          'pluginVersion': '1.0',
          'pluginAuthor': 'Local User',
          'publishedDate': DateTime.now().toIso8601String().split('T')[0],
          'sector': schemaJson['manifest']?['targetAppSector'] ?? 'FDM',
        },
        'schemas': [
          {
            'id': schemaId,
            'version': schemaId.startsWith('v')
                ? schemaId.substring(1)
                : schemaId,
            'releaseDate': DateTime.now().toIso8601String().split('T')[0],
          },
        ],
      };
    }
    await manifestFile.writeAsString(jsonEncode(manifest));

    final schemasDir = Directory(p.join(pluginPath, 'schemas'));
    if (!await schemasDir.exists()) {
      await schemasDir.create(recursive: true);
    }
    final schemaFile = File(p.join(schemasDir.path, '$schemaId.json'));
    await schemaFile.writeAsString(jsonEncode(schemaJson));
  }
}
