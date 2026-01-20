import 'package:laminode_app/features/schema_shop/data/models/base_param_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/base_schema.dart';

class CamBaseSchemaModel {
  final String schemaName;
  final List<CamBaseParamModel> baseParameters;

  const CamBaseSchemaModel({
    required this.schemaName,
    required this.baseParameters,
  });

  factory CamBaseSchemaModel.fromEntity(CamBaseSchema entity) {
    return CamBaseSchemaModel(
      schemaName: entity.schemaName,
      baseParameters: entity.baseParameters
          .map((e) => CamBaseParamModel.fromEntity(e))
          .toList(),
    );
  }

  CamBaseSchema toEntity() {
    return CamBaseSchema(
      schemaName: schemaName,
      baseParameters: baseParameters.map((e) => e.toEntity()).toList(),
    );
  }

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
      'baseParameters': baseParameters.map((e) => e.toJson()).toList(),
    };
  }
}
