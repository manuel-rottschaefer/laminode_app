import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';

void main() {
  final tPluginManifestModel = PluginManifestModel(
    pluginType: 'application',
    displayName: 'Test Plugin',
    description: 'Description',
    application: ApplicationInfoModel(
      appName: 'App',
      appVersion: '1.0.0',
      vendor: 'Vendor',
      website: 'site.com',
      sector: 'FDM',
    ),
    plugin: PluginInfoModel(
      pluginID: 'plugin_1',
      pluginVersion: '1.0.0',
      pluginAuthor: 'Author',
      publishedDate: '2023-01-01',
      sector: 'FDM',
      targetAppVersionRange: TargetAppVersionRangeModel(
        minVersion: '1.0.0',
        maxVersion: '2.0.0',
      ),
      fileTypes: FileTypesModel(
        profileImportBucket: 'import',
        gcodeExportBucket: 'export',
      ),
    ),
    schemas: [
      SchemaRefModel(id: 's1', version: '1.0.0', releaseDate: '2023-01-01'),
    ],
  );

  group('PluginManifestModel', () {
    test('should be a subclass of PluginManifest entity', () {
      expect(tPluginManifestModel, isA<PluginManifest>());
    });

    test('fromJson should return a valid model', () {
      final Map<String, dynamic> jsonMap = {
        'pluginType': 'application',
        'displayName': 'Test Plugin',
        'description': 'Description',
        'application': {
          'appName': 'App',
          'appVersion': '1.0.0',
          'vendor': 'Vendor',
          'website': 'site.com',
          'sector': 'FDM',
        },
        'plugin': {
          'pluginID': 'plugin_1',
          'pluginVersion': '1.0.0',
          'pluginAuthor': 'Author',
          'publishedDate': '2023-01-01',
          'sector': 'FDM',
          'targetAppVersionRange': {'minVersion': '1.0.0', 'maxVersion': '2.0.0'},
          'fileTypes': {
            'profileImportBucket': 'import',
            'gcodeExportBucket': 'export',
          },
        },
        'schemas': [
          {'id': 's1', 'version': '1.0.0', 'releaseDate': '2023-01-01'},
        ],
      };

      final result = PluginManifestModel.fromJson(jsonMap);

      expect(result.pluginType, tPluginManifestModel.pluginType);
      expect(result.displayName, tPluginManifestModel.displayName);
      expect(result.plugin.pluginID, tPluginManifestModel.plugin.pluginID);
      expect(result.schemas.length, 1);
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tPluginManifestModel.toJson();

      expect(result['pluginType'], 'application');
      expect(result['displayName'], 'Test Plugin');
      expect(result['application']['appName'], 'App');
      expect(result['plugin']['pluginID'], 'plugin_1');
      expect(result['schemas'][0]['id'], 's1');
    });
  });
}
