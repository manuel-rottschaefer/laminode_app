import 'package:laminode_app/core/domain/entities/cam_relation.dart';

// A relation entry is a representation of a CamRelation that stores pre-computed references
class ParamRelationEntry extends CamRelation {
  final List<String>? referencedParamNames;

  ParamRelationEntry({
    required super.targetParam,
    required super.expression,
    this.referencedParamNames,
  });
}
