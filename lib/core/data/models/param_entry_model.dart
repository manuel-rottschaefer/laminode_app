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
      paramName: json['paramName'],
      paramTitle: json['paramTitle'],
      paramDescription: json['paramDescription'] ?? json['description'],
      quantity: ParamQuantity.fromJson(json['quantity']),
      category: CamCategoryEntry(
        categoryName: json['category']['categoryName'],
        categoryTitle: json['category']['categoryTitle'],
        categoryColorName: json['category']['categoryColorName'],
        isVisible: json['category']['isVisible'] ?? true,
      ),
      isVisible: json['isVisible'] ?? true,
      value: json['value'],
      isLocked: json['isLocked'] ?? false,
      isEdited: json['isEdited'] ?? false,
      minThreshold: CamExpressionRelationModel.fromJson(
        json['minThreshold'] ?? {'targetParamName': json['paramName']},
      ),
      maxThreshold: CamExpressionRelationModel.fromJson(
        json['maxThreshold'] ?? {'targetParamName': json['paramName']},
      ),
      defaultValue: CamExpressionRelationModel.fromJson(
        json['defaultValue'] ?? {'targetParamName': json['paramName']},
      ),
      suggestedValue: CamExpressionRelationModel.fromJson(
        json['suggestedValue'] ?? {'targetParamName': json['paramName']},
      ),
      enabledCondition: CamExpressionRelationModel.fromJson(
        json['enabledCondition'] ?? {'targetParamName': json['paramName']},
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
      'paramName': paramName,
      'paramTitle': paramTitle,
      'paramDescription': paramDescription,
      'quantity': quantity.toJson(),
      'category': {
        'categoryName': category.categoryName,
        'categoryTitle': category.categoryTitle,
        'categoryColorName': category.categoryColorName,
        'isVisible': category.isVisible,
      },
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
