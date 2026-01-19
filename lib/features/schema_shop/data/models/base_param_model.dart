import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/data/models/cam_category_entry_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/base_param.dart';

class CamBaseParamModel extends CamBaseParam {
  CamBaseParamModel({
    required super.paramName,
    required super.paramTitle,
    required super.quantity,
    required super.category,
  });

  factory CamBaseParamModel.fromJson(Map<String, dynamic> json) {
    return CamBaseParamModel(
      paramName: json['paramName'],
      paramTitle: json['paramTitle'],
      quantity: ParamQuantity.fromJson(json['quantity']),
      category: CamCategoryEntryModel(
        categoryName: json['category']['categoryName'],
        categoryTitle: json['category']['categoryTitle'],
        categoryColorName: json['category']['categoryColorName'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paramName': paramName,
      'paramTitle': paramTitle,
      'quantity': quantity.toJson(),
      'category': CamCategoryEntryModel(
        categoryName: category.categoryName,
        categoryTitle: category.categoryTitle,
        categoryColorName: category.categoryColorName,
      ).toJson(),
    };
  }
}
