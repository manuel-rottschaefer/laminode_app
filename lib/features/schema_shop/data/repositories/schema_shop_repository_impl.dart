import 'dart:convert';
import 'dart:io';
import 'package:laminode_app/features/schema_editor/data/models/cam_schema_entry_model.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/repositories/schema_shop_repository.dart';

class SchemaShopRepositoryImpl implements SchemaShopRepository {
  @override
  Future<CamSchemaEntry?> loadSchema(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) return null;
    final jsonString = await file.readAsString();
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    // Check if it's a regular schema entry or a base schema (if needed)
    // For now assuming CamSchemaEntry as it was defined for .lmds
    return CamSchemaEntryModel.fromJson(jsonMap);
  }
}
