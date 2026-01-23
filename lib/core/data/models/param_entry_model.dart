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
  final dynamic value;
  final bool isLocked;
  final bool isEdited;
  final ParamRelationModel? defaultValue;
  final ParamRelationModel? suggestValue;

  CamParamEntryModel({
    required this.paramName,
    required this.paramTitle,
    this.paramDescription,
    required this.quantity,
    required this.category,
    required this.value,
    this.isLocked = false,
    this.isEdited = false,
    this.defaultValue,
    this.suggestValue,
  });

  factory CamParamEntryModel.fromEntity(CamParamEntry entity) {
    return CamParamEntryModel(
      paramName: entity.paramName,
      paramTitle: entity.paramTitle,
      paramDescription: entity.paramDescription,
      quantity: entity.quantity,
      category: entity.category as CamCategoryEntry,
      value: entity.value,
      isLocked: entity.isLocked,
      isEdited: entity.isEdited,
      defaultValue: entity.defaultValue != null ? ParamRelationModel.fromEntity(entity.defaultValue!) : null,
      suggestValue: entity.suggestValue != null ? ParamRelationModel.fromEntity(entity.suggestValue!) : null,
    );
  }

  CamParamEntry toEntity() {
    return CamParamEntry(
      paramName: paramName,
      paramTitle: paramTitle,
      paramDescription: paramDescription,
      quantity: quantity,
      category: category,
      value: value,
      isLocked: isLocked,
      isEdited: isEdited,
      defaultValue: defaultValue?.toEntity(),
      suggestValue: suggestValue?.toEntity(),
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
      ),
      value: json['value'],
      isLocked: json['isLocked'] ?? false,
      isEdited: json['isEdited'] ?? false,
      defaultValue: json['defaultValue'] != null ? ParamRelationModel.fromJson(json['defaultValue']) : null,
      suggestValue: json['suggestValue'] != null ? ParamRelationModel.fromJson(json['suggestValue']) : null,
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
      },
      'value': value,
      'isLocked': isLocked,
      'isEdited': isEdited,
      'defaultValue': defaultValue?.toJson(),
      'suggestValue': suggestValue?.toJson(),
    };
  }
}
