import 'package:laminode_app/core/domain/entities/cam_param.dart';

class CamSchemaParam extends CamParameter {
  CamSchemaParam({
    required super.paramName,
    required super.paramTitle,
    required String description,
    required super.category,
    required super.quantity,
    super.minThreshold,
    super.maxThreshold,
    super.defaultValue,
    super.suggestedValue,
    super.enabledCondition,
    super.children,
    super.dependentParamNames,
  }) : super(paramDescription: description);

  String get description => paramDescription ?? '';
}
