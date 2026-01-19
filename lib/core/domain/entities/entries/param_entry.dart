import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/profile_editor/domain/entities/param_relation_entry.dart';

// A Parameter entry is a stateful representation of a CamParameter in a Profile
class CamParamEntry extends CamParameter {
  final dynamic value;

  final ParamRelationEntry? defaultValue;
  final ParamRelationEntry? suggestValue;

  CamParamEntry({
    required super.paramName,
    required super.paramTitle,
    required super.quantity,
    required super.category,
    super.baseParam,
    required this.value,
    this.defaultValue,
    this.suggestValue,
  });
}
