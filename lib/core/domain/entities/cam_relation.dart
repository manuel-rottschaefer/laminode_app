// A CAM Relation represents a bound relationship of a CAM Parameter to one or many other parameters
import 'package:laminode_app/core/domain/entities/cam_param.dart';

abstract class CamRelation {
  final CamParameter targetParam;
  final String expression;
  final List<CamParameter> referencedParams;

  const CamRelation({
    required this.targetParam,
    required this.expression,
    this.referencedParams = const [],
  });
}
