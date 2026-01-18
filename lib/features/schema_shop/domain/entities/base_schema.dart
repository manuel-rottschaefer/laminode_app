import 'package:laminode_app/core/domain/entities/cam_schema.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/base_param.dart';

class CamBaseSchema extends CamSchema {
  final List<CamBaseParam> baseParameters;
  CamBaseSchema({required super.schemaName, required this.baseParameters});
}
