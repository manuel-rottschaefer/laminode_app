import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';

abstract class SchemaShopLocalDataSource {
  Future<void> savePlugin(
    PluginManifestModel plugin,
    List<int>? adapterBytes,
    String schemaId,
    Map<String, dynamic> schemaJson,
  );
  Future<void> removePlugin(String pluginId);
  Future<List<PluginManifestModel>> getInstalledPlugins();
  Future<List<String>> getInstalledSchemaIds();
  Future<Map<String, dynamic>?> getInstalledSchema(String schemaId);
  Future<bool> applicationExists(String appName);
  Future<void> saveManualSchema(
    String appName,
    String schemaId,
    Map<String, dynamic> schemaJson,
  );
}

class SchemaShopLocalDataSourceImpl implements SchemaShopLocalDataSource {
  Future<String> get _pluginsPath async {
    final appSupportDir = await getApplicationSupportDirectory();
    return p.join(appSupportDir.path, 'plugins');
  }

  @override
  Future<void> savePlugin(
    PluginManifestModel plugin,
    List<int>? adapterBytes,
    String schemaId,
    Map<String, dynamic> schemaJson,
  ) async {
    final rootPath = await _pluginsPath;
    final pluginId = plugin.plugin.pluginID;
    final pluginPath = p.join(rootPath, pluginId);

    final pluginDir = Directory(pluginPath);
    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
    }

    // Save Manifest
    final manifestFile = File(p.join(pluginPath, 'manifest.json'));
    await manifestFile.writeAsString(jsonEncode(plugin.toJson()));

    // Save Adapter
    if (adapterBytes != null) {
      final adapterFile = File(p.join(pluginPath, 'adapter.js'));
      await adapterFile.writeAsBytes(adapterBytes);
    }

    // Save Schema
    final schemasDir = Directory(p.join(pluginPath, 'schemas'));
    if (!await schemasDir.exists()) {
      await schemasDir.create(recursive: true);
    }
    final schemaFile = File(p.join(schemasDir.path, '$schemaId.json'));
    await schemaFile.writeAsString(jsonEncode(schemaJson));
  }

  @override
  Future<void> removePlugin(String pluginId) async {
    final rootPath = await _pluginsPath;
    final pluginPath = p.join(rootPath, pluginId);
    final pluginDir = Directory(pluginPath);
    if (await pluginDir.exists()) {
      await pluginDir.delete(recursive: true);
    }
  }

  @override
  Future<List<PluginManifestModel>> getInstalledPlugins() async {
    final rootPath = await _pluginsPath;
    final pluginsDir = Directory(rootPath);
    if (!await pluginsDir.exists()) return [];

    final List<PluginManifestModel> plugins = [];
    await for (final pluginDir in pluginsDir.list()) {
      if (pluginDir is Directory) {
        final manifestFile = File(p.join(pluginDir.path, 'manifest.json'));
        if (await manifestFile.exists()) {
          final manifestJson = jsonDecode(await manifestFile.readAsString());
          plugins.add(PluginManifestModel.fromJson(manifestJson));
        }
      }
    }
    return plugins;
  }

  @override
  Future<List<String>> getInstalledSchemaIds() async {
    final rootPath = await _pluginsPath;
    final pluginsDir = Directory(rootPath);
    if (!await pluginsDir.exists()) return [];

    final List<String> schemaIds = [];
    await for (final pluginDir in pluginsDir.list()) {
      if (pluginDir is Directory) {
        final schemasDir = Directory(p.join(pluginDir.path, 'schemas'));
        if (await schemasDir.exists()) {
          await for (final schemaFile in schemasDir.list()) {
            if (schemaFile is File && schemaFile.path.endsWith('.json')) {
              schemaIds.add(p.basenameWithoutExtension(schemaFile.path));
            }
          }
        }
      }
    }
    return schemaIds;
  }

  @override
  Future<Map<String, dynamic>?> getInstalledSchema(String schemaId) async {
    final rootPath = await _pluginsPath;
    final pluginsDir = Directory(rootPath);
    if (!await pluginsDir.exists()) return null;

    await for (final pluginDir in pluginsDir.list()) {
      if (pluginDir is Directory) {
        final schemaFile = File(
          p.join(pluginDir.path, 'schemas', '$schemaId.json'),
        );
        if (await schemaFile.exists()) {
          return jsonDecode(await schemaFile.readAsString());
        }
      }
    }
    return null;
  }

  @override
  Future<bool> applicationExists(String appName) async {
    final appSupportDir = await getApplicationSupportDirectory();
    final appPath = p.join(
      appSupportDir.path,
      'applications',
      appName.replaceAll(' ', '_'),
    );
    return await Directory(appPath).exists();
  }

  @override
  Future<void> saveManualSchema(
    String appName,
    String schemaId,
    Map<String, dynamic> schemaJson,
  ) async {
    final rootPath = await _pluginsPath;
    final pluginId = "manual_${appName.replaceAll(' ', '_').toLowerCase()}";
    final pluginPath = p.join(rootPath, pluginId);

    final pluginDir = Directory(pluginPath);
    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
    }

    // Save/Update Manifest
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

    // Save Schema
    final schemasDir = Directory(p.join(pluginPath, 'schemas'));
    if (!await schemasDir.exists()) {
      await schemasDir.create(recursive: true);
    }
    final schemaFile = File(p.join(schemasDir.path, '$schemaId.json'));
    await schemaFile.writeAsString(jsonEncode(schemaJson));
  }
}
