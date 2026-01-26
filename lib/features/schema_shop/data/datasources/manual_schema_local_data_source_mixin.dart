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
    String appVersion,
    String schemaId,
    Map<String, dynamic> schemaJson,
    String? adapterCode,
  ) async {
    final rootPath = await pluginsPath;

    // Structure: plugins/[app_name]/[app_version]/[schema_version]/
    final sanitizedAppName = appName.replaceAll(' ', '_');
    final sanitizedAppVersion = appVersion.replaceAll(' ', '_');
    final sanitizedSchemaId = schemaId.replaceAll(' ', '_');

    final pluginPath = p.join(
      rootPath,
      sanitizedAppName,
      sanitizedAppVersion,
      sanitizedSchemaId,
    );

    final pluginDir = Directory(pluginPath);
    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
    }

    if (adapterCode != null) {
      final adapterFile = File(p.join(pluginPath, 'adapter.js'));
      await adapterFile.writeAsString(adapterCode);
    }

    final schemaFile = File(p.join(pluginPath, 'schema.json'));
    await schemaFile.writeAsString(jsonEncode(schemaJson));

    // Also update/create a top-level manifest for the app if it doesn't exist
    final appRootPath = p.join(rootPath, sanitizedAppName);
    final manifestFile = File(p.join(appRootPath, 'manifest.json'));

    if (!await manifestFile.exists()) {
      final manifest = {
        'pluginType': 'application',
        'displayName': appName,
        'description': 'Local plugins for $appName',
        'application': {
          'appName': appName,
          'appVersion': appVersion,
          'vendor': 'Local',
          'website': '',
          'sector': schemaJson['manifest']?['targetAppSector'] ?? 'FDM',
        },
        'plugin': {
          'pluginID': sanitizedAppName.toLowerCase(),
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
      await manifestFile.writeAsString(jsonEncode(manifest));
    } else {
      // Update existing manifest schemas list
      final manifest = jsonDecode(await manifestFile.readAsString());
      final List schemas = manifest['schemas'] ?? [];
      if (!schemas.any((s) => s['id'] == schemaId)) {
        schemas.add({
          'id': schemaId,
          'version': schemaId.startsWith('v')
              ? schemaId.substring(1)
              : schemaId,
          'releaseDate': DateTime.now().toIso8601String().split('T')[0],
        });
        manifest['schemas'] = schemas;
        await manifestFile.writeAsString(jsonEncode(manifest));
      }
    }
  }
}
