import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/data/models/schema_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';

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
      baseParam: p['baseParam'],
      quantity: ParamQuantity(
        quantityName: p['quantity']?['name'] ?? 'generic',
        quantityUnit: p['quantity']?['unit'] ?? 'none',
        quantitySymbol: p['quantity']?['symbol'] ?? '',
      ),
      category: category,
      value: null, // Default value or from schema if available
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
