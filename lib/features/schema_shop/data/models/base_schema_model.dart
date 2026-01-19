import 'package:laminode_app/features/schema_shop/data/models/base_param_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/base_schema.dart';

class CamBaseSchemaModel extends CamBaseSchema {
  CamBaseSchemaModel({
    required super.schemaName,
    required super.baseParameters,
  });

  factory CamBaseSchemaModel.fromJson(Map<String, dynamic> json) {
    return CamBaseSchemaModel(
      schemaName: json['schemaName'],
      baseParameters: (json['baseParameters'] as List<dynamic>)
          .map((e) => CamBaseParamModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaName': schemaName,
      'baseParameters': baseParameters
          .map(
            (e) => CamBaseParamModel(
              paramName: e.paramName,
              paramTitle: e.paramTitle,
              quantity: e.quantity,
              category: e.category,
            ).toJson(),
          )
          .toList(),
    };
  }
}
