import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';

void main() {
  group('SchemaManifest', () {
    test('should be initialized correctly', () {
      final manifest = SchemaManifest(
        schemaType: 'application',
        schemaVersion: '1.0',
        schemaAuthors: [],
        lastUpdated: 'date',
        targetAppName: 'App',
        targetAppVersion: '1.0',
        targetAppSector: 'FDM',
      );

      expect(manifest.targetAppName, 'App');
    });
  });
}
