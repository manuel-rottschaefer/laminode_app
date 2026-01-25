import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/data/models/schema_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';

void main() {
  final tSchemaManifestModel = SchemaManifestModel(
    schemaType: 'application',
    schemaVersion: '1.0.0',
    schemaAuthors: ['Author 1'],
    lastUpdated: '2023-01-01',
    targetAppName: 'App',
    targetAppSector: 'FDM',
  );

  group('SchemaManifestModel', () {
    test('should be a subclass of SchemaManifest entity', () {
      expect(tSchemaManifestModel, isA<SchemaManifest>());
    });

    test('fromJson should return a valid model', () {
      final Map<String, dynamic> jsonMap = {
        'schemaType': 'application',
        'schemaVersion': '1.0.0',
        'schemaAuthors': ['Author 1'],
        'lastUpdated': '2023-01-01',
        'targetAppName': 'App',
        'targetAppSector': 'FDM',
      };

      final result = SchemaManifestModel.fromJson(jsonMap);

      expect(result.schemaType, tSchemaManifestModel.schemaType);
      expect(result.schemaVersion, tSchemaManifestModel.schemaVersion);
      expect(result.schemaAuthors, tSchemaManifestModel.schemaAuthors);
      expect(result.lastUpdated, tSchemaManifestModel.lastUpdated);
      expect(result.targetAppName, tSchemaManifestModel.targetAppName);
      expect(result.targetAppSector, tSchemaManifestModel.targetAppSector);
    });

    test('toJson should return a JSON map containing the proper data', () {
      final result = tSchemaManifestModel.toJson();

      final expectedMap = {
        'schemaType': 'application',
        'schemaVersion': '1.0.0',
        'schemaAuthors': ['Author 1'],
        'lastUpdated': '2023-01-01',
        'targetAppName': 'App',
        'targetAppSector': 'FDM',
      };

      expect(result, expectedMap);
    });
  });
}
