import 'package:laminode_app/core/domain/entities/cam_relation.dart';

enum QuantityType { numeric, choice, boolean }

// A ParamQuantity describes the type of parameter being represented
class ParamQuantity {
  final String quantityName;
  final String quantityUnit;
  final String quantitySymbol;
  final QuantityType quantityType;
  final List<String> options;

  const ParamQuantity({
    required this.quantityName,
    required this.quantityUnit,
    required this.quantitySymbol,
    required this.quantityType,
    this.options = const [],
  });

  factory ParamQuantity.fromJson(Map<String, dynamic> json) {
    return ParamQuantity(
      quantityName: json['name'] ?? 'generic',
      quantityUnit: json['unit'] ?? 'none',
      quantitySymbol: json['symbol'] ?? '',
      quantityType: QuantityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuantityType.numeric,
      ),
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': quantityName,
      'unit': quantityUnit,
      'symbol': quantitySymbol,
      'type': quantityType.name,
      'options': options,
    };
  }

  /// Returns a basic default value for this quantity type
  dynamic get fallbackValue {
    switch (quantityType) {
      case QuantityType.numeric:
        return 0;
      case QuantityType.choice:
        return options.isNotEmpty ? options.first : '';
      case QuantityType.boolean:
        return false;
    }
  }

  /// Returns the default value for expression validation (1 for numeric, first option for choice, false for booleans)
  dynamic get validationDefaultValue {
    switch (quantityType) {
      case QuantityType.numeric:
        return 1;
      case QuantityType.choice:
        return options.isNotEmpty ? options.first : '';
      case QuantityType.boolean:
        return false;
    }
  }
}

// Parameters are grouped into categories for better organization
abstract class CamParamCategory {
  final String categoryName;
  final String categoryTitle;
  final String categoryColorName;
  final String? parentCategoryName;
  final bool isVisible;

  const CamParamCategory({
    required this.categoryName,
    required this.categoryTitle,
    required this.categoryColorName,
    this.parentCategoryName,
    this.isVisible = true,
  });
}

// A CamParameter is the atomic unit of configuration for a CAM profile
abstract class CamParameter {
  final String paramName;
  final String paramTitle;
  final String? paramDescription;
  final ParamQuantity quantity;
  final CamParamCategory category;
  final String? baseParam;
  final bool isVisible;

  // Intrinsic mandatory relations
  final CamExpressionRelation minThreshold;
  final CamExpressionRelation maxThreshold;
  final CamExpressionRelation defaultValue;
  final CamExpressionRelation suggestedValue;

  // Conditional enablement
  final CamExpressionRelation enabledCondition;

  // Hierarchy
  final List<CamHierarchyRelation> children;

  /// Parameters that depend on THIS parameter (for cascading updates)
  final List<String> dependentParamNames;

  CamParameter({
    required this.paramName,
    required this.paramTitle,
    this.paramDescription,
    required this.quantity,
    required this.category,
    this.baseParam,
    this.isVisible = true,
    CamExpressionRelation? minThreshold,
    CamExpressionRelation? maxThreshold,
    CamExpressionRelation? defaultValue,
    CamExpressionRelation? suggestedValue,
    CamExpressionRelation? enabledCondition,
    this.children = const [],
    this.dependentParamNames = const [],
  }) : minThreshold =
           minThreshold ??
           CamExpressionRelation(targetParamName: paramName, expression: ''),
       maxThreshold =
           maxThreshold ??
           CamExpressionRelation(targetParamName: paramName, expression: ''),
       defaultValue =
           defaultValue ??
           CamExpressionRelation(targetParamName: paramName, expression: ''),
       suggestedValue =
           suggestedValue ??
           CamExpressionRelation(targetParamName: paramName, expression: ''),
       enabledCondition =
           enabledCondition ??
           CamExpressionRelation(targetParamName: paramName, expression: '');
}
