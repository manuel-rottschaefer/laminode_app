import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';

mixin PluginLocalDataSourceMixin {
  Future<String> get pluginsPath async {
    final appSupportDir = await getApplicationSupportDirectory();
    return p.join(appSupportDir.path, 'plugins');
  }

  Future<void> savePluginImpl(
    PluginManifestModel plugin,
    List<int>? adapterBytes,
    String schemaId,
    Map<String, dynamic> schemaJson,
  ) async {
    final rootPath = await pluginsPath;
    final pluginId = plugin.plugin.pluginID;
    final pluginPath = p.join(rootPath, pluginId);

    final pluginDir = Directory(pluginPath);
    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
    }

    final manifestFile = File(p.join(pluginPath, 'manifest.json'));
    await manifestFile.writeAsString(jsonEncode(plugin.toJson()));

    if (adapterBytes != null) {
      final adapterFile = File(p.join(pluginPath, 'adapter.js'));
      await adapterFile.writeAsBytes(adapterBytes);
    }

    final schemasDir = Directory(p.join(pluginPath, 'schemas'));
    if (!await schemasDir.exists()) {
      await schemasDir.create(recursive: true);
    }
    final schemaFile = File(p.join(schemasDir.path, '$schemaId.json'));
    await schemaFile.writeAsString(jsonEncode(schemaJson));
  }

  Future<void> removePluginImpl(String pluginId) async {
    final rootPath = await pluginsPath;
    final pluginPath = p.join(rootPath, pluginId);
    final pluginDir = Directory(pluginPath);
    if (await pluginDir.exists()) {
      await pluginDir.delete(recursive: true);
    }
  }

  Future<List<PluginManifestModel>> getInstalledPluginsImpl() async {
    final rootPath = await pluginsPath;
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
}
