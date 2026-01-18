import 'package:laminode_app/core/domain/entities/cam_schema.dart';
import 'package:laminode_app/features/schema_shop/data/models/base_param_model.dart';

class CamBaseSchema extends CamSchema {
  final List<CamBaseParam> baseParameters;
  CamBaseSchema({required super.schemaName, required this.baseParameters});
}
