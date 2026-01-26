import 'package:laminode_app/core/domain/entities/cam_param.dart';

class CamCategoryEntry extends CamParamCategory {
  CamCategoryEntry({
    required super.categoryName,
    required super.categoryTitle,
    required super.categoryColorName,
    super.parentCategoryName,
    super.isVisible = true,
  });

  CamCategoryEntry copyWith({
    String? categoryName,
    String? categoryTitle,
    String? categoryColorName,
    String? parentCategoryName,
    bool? isVisible,
  }) {
    return CamCategoryEntry(
      categoryName: categoryName ?? this.categoryName,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categoryColorName: categoryColorName ?? this.categoryColorName,
      parentCategoryName: parentCategoryName ?? this.parentCategoryName,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
