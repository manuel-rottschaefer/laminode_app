import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/profile_editor/domain/entities/param_relation_entry.dart';

// A Parameter entry is a stateful representation of a CamParameter in a Profile
class CamParamEntry extends CamParameter {
  final dynamic value;

  final ParamRelationEntry? defaultValue;
  final ParamRelationEntry? suggestValue;

  const CamParamEntry({
    required super.paramName,
    required super.paramTitle,
    super.paramDescription,
    required super.quantity,
    required super.category,
    super.baseParam,
    required this.value,
    this.defaultValue,
    this.suggestValue,
  });

  CamParamEntry copyWith({
    String? paramName,
    String? paramTitle,
    String? paramDescription,
    ParamQuantity? quantity,
    CamParamCategory? category,
    String? baseParam,
    dynamic value,
    ParamRelationEntry? defaultValue,
    ParamRelationEntry? suggestValue,
  }) {
    return CamParamEntry(
      paramName: paramName ?? this.paramName,
      paramTitle: paramTitle ?? this.paramTitle,
      paramDescription: paramDescription ?? this.paramDescription,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      baseParam: baseParam ?? this.baseParam,
      value: value ?? this.value,
      defaultValue: defaultValue ?? this.defaultValue,
      suggestValue: suggestValue ?? this.suggestValue,
    );
  }
}
