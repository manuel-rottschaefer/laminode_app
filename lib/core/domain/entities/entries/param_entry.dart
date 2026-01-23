import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/profile_editor/domain/entities/param_relation_entry.dart';

// A Parameter entry is a stateful representation of a CamParameter in a Profile
class CamParamEntry extends CamParameter {
  final dynamic value;
  final bool isLocked;
  final bool isEdited;

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
    this.isLocked = false,
    this.isEdited = false,
    this.defaultValue,
    this.suggestValue,
  });

  /// Evaluates the default value of this parameter.
  /// If [defaultValue] is null or its expression is empty, returns the quantity's fallback.
  dynamic evalDefault([Map<String, dynamic>? context]) {
    if (defaultValue == null || (defaultValue!.expression?.isEmpty ?? true)) {
      return quantity.fallbackValue;
    }
    return defaultValue!.eval(context) ?? quantity.fallbackValue;
  }

  /// Evaluates the suggested value of this parameter.
  /// If [suggestValue] is null or its expression is empty, returns the quantity's fallback.
  dynamic evalSuggest([Map<String, dynamic>? context]) {
    if (suggestValue == null || (suggestValue!.expression?.isEmpty ?? true)) {
      return quantity.fallbackValue;
    }
    return suggestValue!.eval(context) ?? quantity.fallbackValue;
  }

  CamParamEntry copyWith({
    String? paramName,
    String? paramTitle,
    String? paramDescription,
    ParamQuantity? quantity,
    CamParamCategory? category,
    String? baseParam,
    dynamic value,
    bool? isLocked,
    bool? isEdited,
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
      isLocked: isLocked ?? this.isLocked,
      isEdited: isEdited ?? this.isEdited,
      defaultValue: defaultValue ?? this.defaultValue,
      suggestValue: suggestValue ?? this.suggestValue,
    );
  }
}
