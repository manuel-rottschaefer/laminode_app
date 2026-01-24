import 'package:laminode_app/core/domain/entities/cam_relation.dart';

enum QuantityType { numeric, choice, boolean }

// A ParamQuantity describes the type of parameter being represented
class ParamQuantity {
  final String quantityName;
  final String quantityUnit;
  final String quantitySymbol;
  final QuantityType quantityType;

  const ParamQuantity({
    required this.quantityName,
    required this.quantityUnit,
    required this.quantitySymbol,
    required this.quantityType,
  });

  factory ParamQuantity.fromJson(Map<String, dynamic> json) {
    return ParamQuantity(
      quantityName: json['quantityName'],
      quantityUnit: json['quantityUnit'],
      quantitySymbol: json['quantitySymbol'],
      quantityType: QuantityType.values.firstWhere(
        (e) => e.name == json['quantityType'],
        orElse: () => QuantityType.numeric,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quantityName': quantityName,
      'quantityUnit': quantityUnit,
      'quantitySymbol': quantitySymbol,
      'quantityType': quantityType.name,
    };
  }

  /// Returns a basic default value for this quantity type
  dynamic get fallbackValue {
    switch (quantityType) {
      case QuantityType.numeric:
        return 0;
      case QuantityType.choice:
        return '';
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
  final bool isVisible;

  const CamParamCategory({
    required this.categoryName,
    required this.categoryTitle,
    required this.categoryColorName,
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
