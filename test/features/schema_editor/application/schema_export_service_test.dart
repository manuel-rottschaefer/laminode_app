import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/application/schema_export_service.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';

void main() {
  group('SchemaExportService', () {
    test(
      'schemaToRawJson should return a valid Map containing manifest and schema',
      () {
        final state = SchemaEditorState(
          schema: CamSchemaEntry(
            schemaName: 'Test Schema',
            categories: [],
            availableParameters: [],
          ),
          manifest: SchemaManifest(
            schemaType: 'application',
            schemaVersion: 'v1.0.0',
            schemaAuthors: ['Author'],
            lastUpdated: '2026-01-27',
            targetAppName: 'Test App',
            targetAppVersion: '1.0',
            targetAppSector: 'FDM',
          ),
          adapterCode: 'code',
        );

        final result = SchemaExportService.schemaToRawJson(state);

        expect(result.containsKey('manifest'), true);
        expect(result['manifest']['schemaAuthors'], contains('Author'));
        expect(result['manifest']['targetAppName'], 'Test App');
        expect(result['schemaName'], 'Test Schema');
      },
    );
  });
}
