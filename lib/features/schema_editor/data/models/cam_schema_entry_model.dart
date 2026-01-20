import 'package:laminode_app/core/data/models/param_entry_model.dart';
import 'package:laminode_app/core/data/models/cam_category_entry_model.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';

class CamSchemaEntryModel {
  final String schemaName;
  final List<CamCategoryEntryModel> categories;
  final List<CamParamEntryModel> availableParameters;

  const CamSchemaEntryModel({
    required this.schemaName,
    required this.categories,
    required this.availableParameters,
  });

  factory CamSchemaEntryModel.fromEntity(CamSchemaEntry entity) {
    return CamSchemaEntryModel(
      schemaName: entity.schemaName,
      categories: entity.categories
          .map((e) => CamCategoryEntryModel.fromEntity(e))
          .toList(),
      availableParameters: entity.availableParameters
          .map((e) => CamParamEntryModel.fromEntity(e))
          .toList(),
    );
  }

  CamSchemaEntry toEntity() {
    return CamSchemaEntry(
      schemaName: schemaName,
      categories: categories.map((e) => e.toEntity()).toList(),
      availableParameters: availableParameters
          .map((e) => e.toEntity())
          .toList(),
    );
  }

  factory CamSchemaEntryModel.fromJson(Map<String, dynamic> json) {
    return CamSchemaEntryModel(
      schemaName: json['schemaName'],
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CamCategoryEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableParameters: (json['availableParameters'] as List<dynamic>)
          .map((e) => CamParamEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaName': schemaName,
      'categories': categories.map((e) => e.toJson()).toList(),
      'availableParameters': availableParameters
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
