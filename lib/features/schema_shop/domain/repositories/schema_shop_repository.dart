import 'dart:io';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';

abstract class SchemaShopRepository {
  Future<List<PluginManifest>> getAvailablePlugins();
  Future<void> installPlugin(PluginManifest plugin, String schemaId);
  Future<void> installManualSchema(File file);
  Future<void> uninstallPlugin(String pluginId);
  Future<CamSchemaEntry?> loadInstalledSchema(String schemaId);
  Future<List<String>> getInstalledSchemaIds();
  Future<List<PluginManifest>> getInstalledPlugins();
  Future<String?> getAdapterCodeForSchema(String schemaId);
  Future<void> saveSchema(
    String appName,
    String appVersion,
    String schemaId,
    Map<String, dynamic> schemaJson,
    String? adapterCode,
  );
  Future<Map<String, dynamic>?> getRawSchema(String schemaId);
  Future<bool> schemaExists(String appName, String appVersion, String schemaId);
  Future<bool> applicationExists(String appName);
}
