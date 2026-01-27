import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/data/models/schema_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';
import 'package:laminode_app/features/profile_editor/data/models/param_relation_model.dart';

class PluginSchemaModel {
  final SchemaManifest manifest;
  final List<CamCategoryEntry> categories;
  final List<CamParamEntry> availableParameters;

  PluginSchemaModel({
    required this.manifest,
    required this.categories,
    required this.availableParameters,
  });

  factory PluginSchemaModel.fromJson(Map<String, dynamic> json) {
    final manifest = SchemaManifestModel.fromJson(json['manifest']);

    List<CamCategoryEntry> categories = [];
    if (json['categories'] != null) {
      categories = (json['categories'] as List<dynamic>).map((cat) {
        return CamCategoryEntry(
          categoryName: cat['name'],
          categoryTitle: cat['title'],
          categoryColorName: cat['color'],
        );
      }).toList();
    }

    List<CamParamEntry> params = [];
    if (json['availableParameters'] is List) {
      params = (json['availableParameters'] as List<dynamic>).map((p) {
        return _parseParam(p, categories);
      }).toList();
    } else if (json['availableParameters'] is Map<String, dynamic>) {
      params = [_parseParam(json['availableParameters'], categories)];
    }

    return PluginSchemaModel(
      manifest: manifest,
      categories: categories,
      availableParameters: params,
    );
  }

  static CamParamEntry _parseParam(
    Map<String, dynamic> p,
    List<CamCategoryEntry> categories,
  ) {
    final catName = p['category'];
    final category = categories.firstWhere(
      (c) => c.categoryName == catName,
      orElse: () => CamCategoryEntry(
        categoryName: catName ?? 'base',
        categoryTitle: catName ?? 'Base Parameters',
        categoryColorName: 'blue',
      ),
    );

    return CamParamEntry(
      paramName: p['name'],
      paramTitle: p['title'],
      paramDescription: p['description'],
      baseParam: p['baseParam'],
      quantity: ParamQuantity.fromJson(p['quantity']),
      category: category,
      value: p['value'],
      minThreshold: p['minThreshold'] != null
          ? CamExpressionRelationModel.fromJson(p['minThreshold']).toEntity()
          : null,
      maxThreshold: p['maxThreshold'] != null
          ? CamExpressionRelationModel.fromJson(p['maxThreshold']).toEntity()
          : null,
      defaultValue: p['defaultValue'] != null
          ? CamExpressionRelationModel.fromJson(p['defaultValue']).toEntity()
          : null,
      enabledCondition: p['enabledCondition'] != null
          ? CamExpressionRelationModel.fromJson(
              p['enabledCondition'],
            ).toEntity()
          : null,
      children:
          (p['children'] as List<dynamic>?)
              ?.map(
                (e) => CamHierarchyRelationModel.fromJson(
                  e as Map<String, dynamic>,
                ).toEntity(),
              )
              .toList() ??
          const [],
    );
  }

  CamSchemaEntry toEntity() {
    return CamSchemaEntry(
      schemaName:
          manifest.targetAppName ?? manifest.targetAppSector ?? 'Unknown',
      categories: categories,
      availableParameters: availableParameters,
    );
  }
}
