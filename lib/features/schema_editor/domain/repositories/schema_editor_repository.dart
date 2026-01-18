import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';

abstract class SchemaEditorRepository {
  Future<CamSchemaEntry?> importSchema(String filePath);
  Future<void> exportSchema(CamSchemaEntry schema, String filePath);
}
