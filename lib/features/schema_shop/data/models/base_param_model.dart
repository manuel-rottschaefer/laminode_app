import 'package:laminode_app/core/domain/entities/cam_param.dart';

// A CAM Base Parameter serves as a translation base for parameters of the same technology
class CamBaseParam extends CamParameter {
  CamBaseParam({
    required super.paramName,
    required super.paramTitle,
    required super.quantity,
  });
}
