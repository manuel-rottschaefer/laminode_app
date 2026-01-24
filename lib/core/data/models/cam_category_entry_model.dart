import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

class CamCategoryEntryModel {
  final String categoryName;
  final String categoryTitle;
  final String categoryColorName;
  final bool isVisible;

  const CamCategoryEntryModel({
    required this.categoryName,
    required this.categoryTitle,
    required this.categoryColorName,
    this.isVisible = true,
  });

  factory CamCategoryEntryModel.fromEntity(CamCategoryEntry entity) {
    return CamCategoryEntryModel(
      categoryName: entity.categoryName,
      categoryTitle: entity.categoryTitle,
      categoryColorName: entity.categoryColorName,
      isVisible: entity.isVisible,
    );
  }

  CamCategoryEntry toEntity() {
    return CamCategoryEntry(
      categoryName: categoryName,
      categoryTitle: categoryTitle,
      categoryColorName: categoryColorName,
      isVisible: isVisible,
    );
  }

  factory CamCategoryEntryModel.fromJson(Map<String, dynamic> json) {
    return CamCategoryEntryModel(
      categoryName: json['categoryName'],
      categoryTitle: json['categoryTitle'] ?? json['categoryName'],
      categoryColorName: json['categoryColorName'] ?? 'grey',
      isVisible: json['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'categoryTitle': categoryTitle,
      'categoryColorName': categoryColorName,
      'isVisible': isVisible,
    };
  }
}
