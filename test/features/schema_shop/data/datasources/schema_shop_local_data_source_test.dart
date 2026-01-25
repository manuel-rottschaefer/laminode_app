import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_local_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart'
    show MockPlatformInterfaceMixin;
import 'package:path/path.dart' as p;

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String _appSupportPath;
  MockPathProviderPlatform(this._appSupportPath);

  @override
  Future<String?> getApplicationSupportPath() async => _appSupportPath;
}

void main() {
  group('SchemaShopLocalDataSource', () {
    late SchemaShopLocalDataSourceImpl dataSource;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('test_schema_shop');
      PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
      dataSource = SchemaShopLocalDataSourceImpl();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    final tPlugin = PluginManifestModel(
      pluginType: 'application',
      displayName: 'Test App',
      description: 'Desc',
      application: ApplicationInfoModel(
        appName: 'Test App',
        appVersion: '1.0',
        vendor: 'Vendor',
        website: '',
        sector: 'FDM',
      ),
      plugin: PluginInfoModel(
        pluginID: 'test_app_plugin',
        pluginVersion: '1.0',
        pluginAuthor: 'Author',
        publishedDate: '2023-01-01',
        sector: 'FDM',
      ),
      schemas: [
        SchemaRefModel(id: 'schema_1', version: '1.0', releaseDate: '2023-01-01'),
      ],
    );

    final tSchemaJson = {
      'manifest': {'schemaVersion': '1.0', 'targetAppName': 'Test App'},
      'categories': [],
      'availableParameters': [],
    };

    test('savePlugin should create files in the correct structure', () async {
      await dataSource.savePlugin(
        tPlugin,
        utf8.encode('// adapter'),
        'schema_1',
        tSchemaJson,
      );

      final pluginPath = p.join(tempDir.path, 'plugins', 'test_app_plugin');
      expect(await Directory(pluginPath).exists(), true);
      expect(await File(p.join(pluginPath, 'manifest.json')).exists(), true);
      expect(await File(p.join(pluginPath, 'adapter.js')).exists(), true);
      expect(
        await File(p.join(pluginPath, 'schemas', 'schema_1.json')).exists(),
        true,
      );
    });

    test('getInstalledPlugins should return list of installed plugins', () async {
      await dataSource.savePlugin(tPlugin, null, 'schema_1', tSchemaJson);

      final plugins = await dataSource.getInstalledPlugins();

      expect(plugins.length, 1);
      expect(plugins.first.plugin.pluginID, 'test_app_plugin');
    });

    test('removePlugin should delete the plugin directory', () async {
      await dataSource.savePlugin(tPlugin, null, 'schema_1', tSchemaJson);
      await dataSource.removePlugin('test_app_plugin');

      final pluginPath = p.join(tempDir.path, 'plugins', 'test_app_plugin');
      expect(await Directory(pluginPath).exists(), false);
    });

    test('applicationExists should check for app directory', () async {
      final appPath = p.join(tempDir.path, 'applications', 'Test_App');
      await Directory(appPath).create(recursive: true);

      final exists = await dataSource.applicationExists('Test App');
      expect(exists, true);

      final notExists = await dataSource.applicationExists('Other App');
      expect(notExists, false);
    });

    test('saveManualSchema should create manual plugin', () async {
      await dataSource.saveManualSchema(
        'Manual App',
        'v1',
        tSchemaJson,
        '// adapter',
      );

      final pluginId = 'manual_manual_app';
      final pluginPath = p.join(tempDir.path, 'plugins', pluginId);
      expect(await Directory(pluginPath).exists(), true);
      expect(
        await File(p.join(pluginPath, 'schemas', 'v1.json')).exists(),
        true,
      );
    });
  });
}
