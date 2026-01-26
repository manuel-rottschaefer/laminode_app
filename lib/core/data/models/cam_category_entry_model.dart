import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

class CamCategoryEntryModel {
  final String categoryName;
  final String categoryTitle;
  final String categoryColorName;
  final String? parentCategoryName;
  final bool isVisible;

  const CamCategoryEntryModel({
    required this.categoryName,
    required this.categoryTitle,
    required this.categoryColorName,
    this.parentCategoryName,
    this.isVisible = true,
  });

  factory CamCategoryEntryModel.fromEntity(CamCategoryEntry entity) {
    return CamCategoryEntryModel(
      categoryName: entity.categoryName,
      categoryTitle: entity.categoryTitle,
      categoryColorName: entity.categoryColorName,
      parentCategoryName: entity.parentCategoryName,
      isVisible: entity.isVisible,
    );
  }

  CamCategoryEntry toEntity() {
    return CamCategoryEntry(
      categoryName: categoryName,
      categoryTitle: categoryTitle,
      categoryColorName: categoryColorName,
      parentCategoryName: parentCategoryName,
      isVisible: isVisible,
    );
  }

  factory CamCategoryEntryModel.fromJson(Map<String, dynamic> json) {
    return CamCategoryEntryModel(
      categoryName: json['name'],
      categoryTitle: json['title'],
      categoryColorName: json['color'],
      parentCategoryName: json['parent'],
      isVisible: json['isVisible'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': categoryName,
      'title': categoryTitle,
      'color': categoryColorName,
      'parent': parentCategoryName,
      'isVisible': isVisible,
    };
  }
}
