import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/data/models/cam_category_entry_model.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/base_param.dart';

class CamBaseParamModel {
  final String paramName;
  final String paramTitle;
  final ParamQuantity quantity;
  final CamCategoryEntryModel category;

  const CamBaseParamModel({
    required this.paramName,
    required this.paramTitle,
    required this.quantity,
    required this.category,
  });

  factory CamBaseParamModel.fromEntity(CamBaseParam entity) {
    return CamBaseParamModel(
      paramName: entity.paramName,
      paramTitle: entity.paramTitle,
      quantity: entity.quantity,
      category: CamCategoryEntryModel.fromEntity(entity.category as dynamic),
    );
  }

  CamBaseParam toEntity() {
    return CamBaseParam(
      paramName: paramName,
      paramTitle: paramTitle,
      quantity: quantity,
      category: category.toEntity(),
    );
  }

  factory CamBaseParamModel.fromJson(Map<String, dynamic> json) {
    return CamBaseParamModel(
      paramName: json['paramName'],
      paramTitle: json['paramTitle'],
      quantity: ParamQuantity.fromJson(json['quantity']),
      category: CamCategoryEntryModel.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paramName': paramName,
      'paramTitle': paramTitle,
      'quantity': quantity.toJson(),
      'category': category.toJson(),
    };
  }
}
