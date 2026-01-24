import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/plugin_local_data_source_mixin.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/manual_schema_local_data_source_mixin.dart';

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
    String? adapterCode,
  );
  Future<String?> getAdapterCodeForSchema(String schemaId);
}

class SchemaShopLocalDataSourceImpl
    with PluginLocalDataSourceMixin, ManualSchemaLocalDataSourceMixin
    implements SchemaShopLocalDataSource {
  @override
  Future<String> get pluginsPath async {
    final appSupportDir = await getApplicationSupportDirectory();
    return p.join(appSupportDir.path, 'plugins');
  }

  @override
  Future<void> savePlugin(
    PluginManifestModel plugin,
    List<int>? adapterBytes,
    String schemaId,
    Map<String, dynamic> schemaJson,
  ) => savePluginImpl(plugin, adapterBytes, schemaId, schemaJson);

  @override
  Future<void> removePlugin(String pluginId) => removePluginImpl(pluginId);

  @override
  Future<List<PluginManifestModel>> getInstalledPlugins() =>
      getInstalledPluginsImpl();

  @override
  Future<List<String>> getInstalledSchemaIds() async {
    final rootPath = await pluginsPath;
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
    final rootPath = await pluginsPath;
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
  Future<bool> applicationExists(String appName) =>
      applicationExistsImpl(appName);

  @override
  Future<void> saveManualSchema(
    String appName,
    String schemaId,
    Map<String, dynamic> schemaJson,
    String? adapterCode,
  ) => saveManualSchemaImpl(appName, schemaId, schemaJson, adapterCode);

  @override
  Future<String?> getAdapterCodeForSchema(String schemaId) async {
    final rootPath = await pluginsPath;
    final pluginsDir = Directory(rootPath);
    if (!await pluginsDir.exists()) return null;

    await for (final pluginDir in pluginsDir.list()) {
      if (pluginDir is Directory) {
        final schemaFile = File(
          p.join(pluginDir.path, 'schemas', '$schemaId.json'),
        );
        if (await schemaFile.exists()) {
          final adapterFile = File(p.join(pluginDir.path, 'adapter.js'));
          if (await adapterFile.exists()) {
            return await adapterFile.readAsString();
          }
        }
      }
    }
    return null;
  }
}
