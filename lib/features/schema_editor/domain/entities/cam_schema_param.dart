import 'package:laminode_app/core/domain/entities/cam_param.dart';

class CamSchemaParam extends CamParameter {
  const CamSchemaParam({
    required super.paramName,
    required super.paramTitle,
    required String description,
    required super.category,
    required super.quantity,
  }) : super(paramDescription: description);

  String get description => paramDescription ?? '';
}
