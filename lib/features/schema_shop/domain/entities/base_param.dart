import 'package:laminode_app/core/domain/entities/cam_param.dart';

class CamBaseParam extends CamParameter {
  CamBaseParam({
    required super.paramName,
    required super.paramTitle,
    required super.quantity,
    required super.category,
    super.minThreshold,
    super.maxThreshold,
    super.defaultValue,
    super.suggestedValue,
    super.enabledCondition,
    super.children,
    super.dependentParamNames,
  });
}
