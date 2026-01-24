import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';

// A Parameter entry is a stateful representation of a CamParameter in a Profile
class CamParamEntry extends CamParameter {
  final dynamic value;
  final bool isLocked;
  final bool isEdited;

  CamParamEntry({
    required super.paramName,
    required super.paramTitle,
    super.paramDescription,
    required super.quantity,
    required super.category,
    super.baseParam,
    super.isVisible = true,
    super.minThreshold,
    super.maxThreshold,
    super.defaultValue,
    super.suggestedValue,
    super.enabledCondition,
    super.children,
    super.dependentParamNames,
    required this.value,
    this.isLocked = false,
    this.isEdited = false,
  });

  /// Evaluates the default value of this parameter using an optional context.
  /// NOTE: This returns the quantity's fallback if no expression or engine is available.
  dynamic evalDefault([Map<String, dynamic>? context]) {
    if (defaultValue.isEmpty) {
      return quantity.fallbackValue;
    }
    // This is a placeholder for backward compatibility.
    // Ideally, use CamRelationService for evaluation.
    return quantity.fallbackValue;
  }

  /// Evaluates the suggested value of this parameter.
  dynamic evalSuggest([Map<String, dynamic>? context]) {
    if (suggestedValue.isEmpty) {
      return quantity.fallbackValue;
    }
    return quantity.fallbackValue;
  }

  CamParamEntry copyWith({
    String? paramName,
    String? paramTitle,
    String? paramDescription,
    ParamQuantity? quantity,
    CamParamCategory? category,
    String? baseParam,
    bool? isVisible,
    CamExpressionRelation? minThreshold,
    CamExpressionRelation? maxThreshold,
    CamExpressionRelation? defaultValue,
    CamExpressionRelation? suggestedValue,
    CamExpressionRelation? enabledCondition,
    List<CamHierarchyRelation>? children,
    List<String>? dependentParamNames,
    dynamic value,
    bool? isLocked,
    bool? isEdited,
  }) {
    return CamParamEntry(
      paramName: paramName ?? this.paramName,
      paramTitle: paramTitle ?? this.paramTitle,
      paramDescription: paramDescription ?? this.paramDescription,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      baseParam: baseParam ?? this.baseParam,
      isVisible: isVisible ?? this.isVisible,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      defaultValue: defaultValue ?? this.defaultValue,
      suggestedValue: suggestedValue ?? this.suggestedValue,
      enabledCondition: enabledCondition ?? this.enabledCondition,
      children: children ?? this.children,
      dependentParamNames: dependentParamNames ?? this.dependentParamNames,
      value: value ?? this.value,
      isLocked: isLocked ?? this.isLocked,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
