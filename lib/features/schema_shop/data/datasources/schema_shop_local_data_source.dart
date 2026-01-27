import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/plugin_local_data_source_mixin.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/manual_schema_local_data_source_mixin.dart';

abstract class SchemaShopLocalDataSource {
  Future<String> get pluginsPath;
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
  Future<bool> schemaExists(String appName, String appVersion, String schemaId);
  Future<void> saveManualSchema(
    String appName,
    String appVersion,
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
  Future<bool> schemaExists(
    String appName,
    String appVersion,
    String schemaId,
  ) async {
    final pluginsBase = await pluginsPath;
    final schemaFile = File(
      p.join(
        pluginsBase,
        'applications',
        appName,
        appVersion,
        'schemas',
        '$schemaId.json',
      ),
    );
    return await schemaFile.exists();
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
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return [];

    final List<String> schemaIds = [];

    // Helper for recursive search
    Future<void> findSchemas(Directory dir) async {
      await for (final entity in dir.list()) {
        if (entity is Directory) {
          // If it's a 'schemas' folder (old structure)
          if (p.basename(entity.path) == 'schemas') {
            await for (final file in entity.list()) {
              if (file is File && file.path.endsWith('.json')) {
                schemaIds.add(p.basenameWithoutExtension(file.path));
              }
            }
          } else {
            // Recursive dive
            await findSchemas(entity);
          }
        } else if (entity is File && p.basename(entity.path) == 'schema.json') {
          // Schema ID is the name of the parent folder
          schemaIds.add(p.basename(dir.path));
        }
      }
    }

    await findSchemas(rootDir);
    return schemaIds;
  }

  @override
  Future<Map<String, dynamic>?> getInstalledSchema(String schemaId) async {
    final rootPath = await pluginsPath;
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return null;

    Map<String, dynamic>? result;

    Future<void> search(Directory dir) async {
      if (result != null) return;

      await for (final entity in dir.list()) {
        if (result != null) return;

        if (entity is Directory) {
          if (p.basename(entity.path) == 'schemas') {
            final file = File(p.join(entity.path, '$schemaId.json'));
            if (await file.exists()) {
              result = jsonDecode(await file.readAsString());
              return;
            }
          } else if (p.basename(entity.path) == schemaId) {
            final file = File(p.join(entity.path, 'schema.json'));
            if (await file.exists()) {
              result = jsonDecode(await file.readAsString());
              return;
            }
          }
          await search(entity);
        }
      }
    }

    await search(rootDir);
    return result;
  }

  @override
  Future<bool> applicationExists(String appName) =>
      applicationExistsImpl(appName);

  @override
  Future<void> saveManualSchema(
    String appName,
    String appVersion,
    String schemaId,
    Map<String, dynamic> schemaJson,
    String? adapterCode,
  ) => saveManualSchemaImpl(
    appName,
    appVersion,
    schemaId,
    schemaJson,
    adapterCode,
  );

  @override
  Future<String?> getAdapterCodeForSchema(String schemaId) async {
    final rootPath = await pluginsPath;
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return null;

    String? code;

    Future<void> search(Directory dir) async {
      if (code != null) return;

      await for (final entity in dir.list()) {
        if (code != null) return;

        if (entity is Directory) {
          // Old structure: adapter.js is in the plugin root
          // If this directory contains 'schemas/[schemaId].json', adapter is here.
          final schemasDir = Directory(p.join(entity.path, 'schemas'));
          if (await schemasDir.exists()) {
            if (await File(
              p.join(schemasDir.path, '$schemaId.json'),
            ).exists()) {
              final adapterFile = File(p.join(entity.path, 'adapter.js'));
              if (await adapterFile.exists()) {
                code = await adapterFile.readAsString();
                return;
              }
            }
          }

          if (p.basename(entity.path) == schemaId) {
            final adapterFile = File(p.join(entity.path, 'adapter.js'));
            if (await adapterFile.exists()) {
              code = await adapterFile.readAsString();
              return;
            }
          }
          await search(entity);
        }
      }
    }

    await search(rootDir);
    return code;
  }
}
