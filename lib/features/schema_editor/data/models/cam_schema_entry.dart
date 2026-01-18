import 'package:laminode_app/core/domain/entities/cam_schema.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_entry.dart';
import 'package:laminode_app/features/schema_editor/data/models/cam_category_entry.dart';

class CamSchemaEntry extends CamSchema {
  final List<CamCategoryEntry> categories;
  final List<CamParamEntry> availableParameters;
  CamSchemaEntry({
    required super.schemaName,
    required this.categories,
    required this.availableParameters,
  });
}
