import 'package:laminode_app/core/domain/entities/cam_param.dart';

class CamSchemaParam extends CamParameter {
  final String description;
  CamSchemaParam({
    required super.paramName,
    required super.paramTitle,
    required this.description,
    required super.category,
    required super.quantity,
  });
}
