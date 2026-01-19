import 'package:laminode_app/features/param_panel/data/models/param_entry_model.dart';
import 'package:laminode_app/features/schema_editor/data/models/cam_category_entry_model.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';

class CamSchemaEntryModel extends CamSchemaEntry {
  CamSchemaEntryModel({
    required super.schemaName,
    required super.categories,
    required super.availableParameters,
  });

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
      'categories': categories
          .map(
            (e) => CamCategoryEntryModel(
              categoryName: e.categoryName,
              categoryTitle: e.categoryTitle,
              categoryColorName: e.categoryColorName,
            ).toJson(),
          )
          .toList(),
      'availableParameters': availableParameters
          .map((e) => (e as CamParamEntryModel).toJson())
          .toList(),
    };
  }
}
