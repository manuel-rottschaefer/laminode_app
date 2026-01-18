import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';

abstract class SchemaShopRepository {
  Future<CamSchemaEntry?> loadSchema(String filePath);
}
