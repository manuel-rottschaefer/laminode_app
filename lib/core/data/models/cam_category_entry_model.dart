import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

class CamCategoryEntryModel extends CamCategoryEntry {
  CamCategoryEntryModel({
    required super.categoryName,
    required super.categoryTitle,
    required super.categoryColorName,
  });

  factory CamCategoryEntryModel.fromJson(Map<String, dynamic> json) {
    return CamCategoryEntryModel(
      categoryName: json['categoryName'],
      categoryTitle: json['categoryTitle'],
      categoryColorName: json['categoryColorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'categoryName': categoryName};
  }
}
