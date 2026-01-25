import 'dart:convert';
import 'dart:io';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_local_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_remote_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_schema_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/domain/repositories/schema_shop_repository.dart';

class SchemaShopRepositoryImpl implements SchemaShopRepository {
  final SchemaShopRemoteDataSource _remoteDataSource;
  final SchemaShopLocalDataSource _localDataSource;

  SchemaShopRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<List<PluginManifest>> getAvailablePlugins() async {
    return await _remoteDataSource.getAvailablePlugins();
  }

  @override
  Future<void> installPlugin(PluginManifest plugin, String schemaId) async {
    final pluginId = plugin.plugin.pluginID;

    List<int>? adapterBytes;
    if (plugin.pluginType == 'application') {
      adapterBytes = await _remoteDataSource.downloadAdapter(pluginId);
    }

    final schemaJson = await _remoteDataSource.downloadSchema(
      pluginId,
      schemaId,
    );

    await _localDataSource.savePlugin(
      plugin as PluginManifestModel,
      adapterBytes,
      schemaId,
      schemaJson,
    );
  }

  @override
  Future<void> installManualSchema(File file) async {
    final content = await file.readAsString();
    final json = jsonDecode(content);

    // Basic validation of schema structure
    if (json['manifest'] == null) {
      throw const FormatException("Invalid schema format: missing manifest");
    }

    final targetAppName = json['manifest']['targetAppName'];
    if (targetAppName == null) {
      throw const FormatException(
        "Invalid schema format: missing targetAppName",
      );
    }

    // Verify application existence in app support dir
    if (!await _localDataSource.applicationExists(targetAppName)) {
      throw Exception(
        "Application '$targetAppName' is not installed in the system.",
      );
    }

    final schemaId = json['manifest']['schemaVersion'] ?? 'manual';

    await _localDataSource.saveManualSchema(
      targetAppName,
      schemaId,
      json,
      null,
    );
  }

  @override
  Future<void> uninstallPlugin(String pluginId) async {
    await _localDataSource.removePlugin(pluginId);
  }

  @override
  Future<CamSchemaEntry?> loadInstalledSchema(String schemaId) async {
    final schemaJson = await _localDataSource.getInstalledSchema(schemaId);
    if (schemaJson != null) {
      return PluginSchemaModel.fromJson(schemaJson).toEntity();
    }
    return null;
  }

  @override
  Future<List<String>> getInstalledSchemaIds() async {
    return await _localDataSource.getInstalledSchemaIds();
  }

  @override
  Future<List<PluginManifest>> getInstalledPlugins() async {
    return await _localDataSource.getInstalledPlugins();
  }

  @override
  Future<String?> getAdapterCodeForSchema(String schemaId) async {
    return await _localDataSource.getAdapterCodeForSchema(schemaId);
  }

  @override
  Future<void> saveSchema(
    String appName,
    String schemaId,
    Map<String, dynamic> schemaJson,
    String? adapterCode,
  ) async {
    await _localDataSource.saveManualSchema(
      appName,
      schemaId,
      schemaJson,
      adapterCode,
    );
  }

  @override
  Future<Map<String, dynamic>?> getRawSchema(String schemaId) async {
    return await _localDataSource.getInstalledSchema(schemaId);
  }

  @override
  Future<bool> schemaExists(String schemaId) async {
    final schema = await _localDataSource.getInstalledSchema(schemaId);
    return schema != null;
  }

  @override
  Future<bool> applicationExists(String appName) async {
    return await _localDataSource.applicationExists(appName);
  }
}
