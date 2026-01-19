import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

class CamCategoryEntryModel {
  final String categoryName;
  final String categoryTitle;
  final String categoryColorName;

  const CamCategoryEntryModel({
    required this.categoryName,
    required this.categoryTitle,
    required this.categoryColorName,
  });

  factory CamCategoryEntryModel.fromEntity(CamCategoryEntry entity) {
    return CamCategoryEntryModel(
      categoryName: entity.categoryName,
      categoryTitle: entity.categoryTitle,
      categoryColorName: entity.categoryColorName,
    );
  }

  CamCategoryEntry toEntity() {
    return CamCategoryEntry(
      categoryName: categoryName,
      categoryTitle: categoryTitle,
      categoryColorName: categoryColorName,
    );
  }

  factory CamCategoryEntryModel.fromJson(Map<String, dynamic> json) {
    return CamCategoryEntryModel(
      categoryName: json['categoryName'],
      categoryTitle: json['categoryTitle'] ?? json['categoryName'],
      categoryColorName: json['categoryColorName'] ?? 'grey',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'categoryTitle': categoryTitle,
      'categoryColorName': categoryColorName,
    };
  }
}
