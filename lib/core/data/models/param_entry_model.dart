import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

class CamParamEntryModel {
  final String paramName;
  final String paramTitle;
  final String? paramDescription;
  final ParamQuantity quantity;
  final CamCategoryEntry category;
  final dynamic value;

  CamParamEntryModel({
    required this.paramName,
    required this.paramTitle,
    this.paramDescription,
    required this.quantity,
    required this.category,
    required this.value,
  });

  factory CamParamEntryModel.fromEntity(CamParamEntry entity) {
    return CamParamEntryModel(
      paramName: entity.paramName,
      paramTitle: entity.paramTitle,
      paramDescription: entity.paramDescription,
      quantity: entity.quantity,
      category: entity.category as CamCategoryEntry,
      value: entity.value,
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
    };
  }
}
