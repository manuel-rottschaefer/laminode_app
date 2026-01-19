import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_entry.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_category_entry.dart';

class CamParamEntryModel extends CamParamEntry {
  CamParamEntryModel({
    required super.paramName,
    required super.paramTitle,
    required super.quantity,
    required super.category,
    required super.value,
  });

  factory CamParamEntryModel.fromJson(Map<String, dynamic> json) {
    return CamParamEntryModel(
      paramName: json['paramName'],
      paramTitle: json['paramTitle'],
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
      'quantity': quantity.toJson(),
      'value': value,
    };
  }
}
