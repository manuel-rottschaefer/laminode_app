import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';

void main() {
  group('SchemaEditorState', () {
    final tSchema = CamSchemaEntry(
      schemaName: 'Test',
      categories: [],
      availableParameters: [],
    );
    final tManifest = SchemaManifest(
      schemaType: 'application',
      schemaVersion: '1.0',
      schemaAuthors: [],
      lastUpdated: 'date',
      targetAppName: 'App',
      targetAppVersion: '1.0',
      targetAppSector: 'FDM',
    );

    test('canSave should return true when valid', () {
      final state = SchemaEditorState(
        schema: tSchema,
        manifest: tManifest,
        isChecking: false,
      );

      expect(state.canSave, true);
    });

    test('copyWith should respect clear flags', () {
      final state = SchemaEditorState(
        schema: tSchema,
        manifest: tManifest,
        selectedParameter: null, // add mock later if needed
      );

      final updated = state.copyWith(clearSelectedParameter: true);
      expect(updated.selectedParameter, null);
    });
  });
}
