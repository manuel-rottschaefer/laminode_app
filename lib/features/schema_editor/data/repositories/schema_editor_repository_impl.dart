import 'dart:convert';
import 'dart:io';
import 'package:laminode_app/features/schema_editor/data/models/cam_schema_entry_model.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_editor/domain/repositories/schema_editor_repository.dart';

class SchemaEditorRepositoryImpl implements SchemaEditorRepository {
  @override
  Future<void> exportSchema(CamSchemaEntry schema, String filePath) async {
    final model = CamSchemaEntryModel.fromEntity(schema);

    final jsonString = jsonEncode(model.toJson());
    final file = File(filePath);
    await file.writeAsString(jsonString);
  }

  @override
  Future<CamSchemaEntry?> importSchema(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return CamSchemaEntryModel.fromJson(jsonMap).toEntity();
  }
}
