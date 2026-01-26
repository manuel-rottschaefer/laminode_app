import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/profile_editor/data/models/param_relation_model.dart';

class CamParamEntryModel {
  final String paramName;
  final String paramTitle;
  final String? paramDescription;
  final ParamQuantity quantity;
  final CamCategoryEntry category;
  final bool isVisible;
  final dynamic value;
  final bool isLocked;
  final bool isEdited;

  final CamExpressionRelationModel minThreshold;
  final CamExpressionRelationModel maxThreshold;
  final CamExpressionRelationModel defaultValue;
  final CamExpressionRelationModel suggestedValue;
  final CamExpressionRelationModel enabledCondition;
  final List<CamHierarchyRelationModel> children;

  CamParamEntryModel({
    required this.paramName,
    required this.paramTitle,
    this.paramDescription,
    required this.quantity,
    required this.category,
    this.isVisible = true,
    required this.value,
    this.isLocked = false,
    this.isEdited = false,
    CamExpressionRelationModel? minThreshold,
    CamExpressionRelationModel? maxThreshold,
    CamExpressionRelationModel? defaultValue,
    CamExpressionRelationModel? suggestedValue,
    CamExpressionRelationModel? enabledCondition,
    this.children = const [],
  }) : minThreshold =
           minThreshold ??
           CamExpressionRelationModel(
             targetParamName: paramName,
             expression: '',
           ),
       maxThreshold =
           maxThreshold ??
           CamExpressionRelationModel(
             targetParamName: paramName,
             expression: '',
           ),
       defaultValue =
           defaultValue ??
           CamExpressionRelationModel(
             targetParamName: paramName,
             expression: '',
           ),
       suggestedValue =
           suggestedValue ??
           CamExpressionRelationModel(
             targetParamName: paramName,
             expression: '',
           ),
       enabledCondition =
           enabledCondition ??
           CamExpressionRelationModel(
             targetParamName: paramName,
             expression: '',
           );

  factory CamParamEntryModel.fromEntity(CamParamEntry entity) {
    return CamParamEntryModel(
      paramName: entity.paramName,
      paramTitle: entity.paramTitle,
      paramDescription: entity.paramDescription,
      quantity: entity.quantity,
      category: entity.category as CamCategoryEntry,
      isVisible: entity.isVisible,
      value: entity.value,
      isLocked: entity.isLocked,
      isEdited: entity.isEdited,
      minThreshold: CamExpressionRelationModel.fromEntity(entity.minThreshold),
      maxThreshold: CamExpressionRelationModel.fromEntity(entity.maxThreshold),
      defaultValue: CamExpressionRelationModel.fromEntity(entity.defaultValue),
      suggestedValue: CamExpressionRelationModel.fromEntity(
        entity.suggestedValue,
      ),
      enabledCondition: CamExpressionRelationModel.fromEntity(
        entity.enabledCondition,
      ),
      children: entity.children
          .map((e) => CamHierarchyRelationModel.fromEntity(e))
          .toList(),
    );
  }

  CamParamEntry toEntity() {
    return CamParamEntry(
      paramName: paramName,
      paramTitle: paramTitle,
      paramDescription: paramDescription,
      quantity: quantity,
      category: category,
      isVisible: isVisible,
      value: value,
      isLocked: isLocked,
      isEdited: isEdited,
      minThreshold: minThreshold.toEntity(),
      maxThreshold: maxThreshold.toEntity(),
      defaultValue: defaultValue.toEntity(),
      suggestedValue: suggestedValue.toEntity(),
      enabledCondition: enabledCondition.toEntity(),
      children: children.map((e) => e.toEntity()).toList(),
      dependentParamNames: const [],
    );
  }

  factory CamParamEntryModel.fromJson(Map<String, dynamic> json) {
    return CamParamEntryModel(
      paramName: json['name'],
      paramTitle: json['title'],
      paramDescription: json['description'],
      quantity: ParamQuantity.fromJson(
        json['quantity'] as Map<String, dynamic>,
      ),
      category: CamCategoryEntry(
        categoryName: json['category'] is String
            ? (json['category'] as String)
            : (json['category'] as Map<String, dynamic>)['name'],
        categoryTitle: json['category'] is Map<String, dynamic>
            ? (json['category'] as Map<String, dynamic>)['title'] ?? ''
            : '',
        categoryColorName: json['category'] is Map<String, dynamic>
            ? (json['category'] as Map<String, dynamic>)['color'] ?? 'blue'
            : 'blue',
      ),
      isVisible: json['isVisible'] ?? true,
      value: json['value'],
      isLocked: json['isLocked'] ?? false,
      isEdited: json['isEdited'] ?? false,
      minThreshold: CamExpressionRelationModel.fromJson(
        json['minThreshold'] ?? {'target': json['name']},
      ),
      maxThreshold: CamExpressionRelationModel.fromJson(
        json['maxThreshold'] ?? {'target': json['name']},
      ),
      defaultValue: CamExpressionRelationModel.fromJson(
        json['defaultValue'] ?? {'target': json['name']},
      ),
      suggestedValue: CamExpressionRelationModel.fromJson(
        json['suggestedValue'] ?? {'target': json['name']},
      ),
      enabledCondition: CamExpressionRelationModel.fromJson(
        json['enabledCondition'] ?? {'target': json['name']},
      ),
      children:
          (json['children'] as List<dynamic>?)
              ?.map(
                (e) => CamHierarchyRelationModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': paramName,
      'title': paramTitle,
      'description': paramDescription,
      'quantity': quantity.toJson(),
      'category': category.categoryName,
      'isVisible': isVisible,
      'value': value,
      'isLocked': isLocked,
      'isEdited': isEdited,
      'minThreshold': minThreshold.toJson(),
      'maxThreshold': maxThreshold.toJson(),
      'defaultValue': defaultValue.toJson(),
      'suggestedValue': suggestedValue.toJson(),
      'enabledCondition': enabledCondition.toJson(),
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
