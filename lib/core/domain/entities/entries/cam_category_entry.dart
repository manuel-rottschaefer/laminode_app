import 'package:laminode_app/core/domain/entities/cam_param.dart';

class CamCategoryEntry extends CamParamCategory {
  CamCategoryEntry({
    required super.categoryName,
    required super.categoryTitle,
    required super.categoryColorName,
    super.isVisible = true,
  });

  CamCategoryEntry copyWith({
    String? categoryName,
    String? categoryTitle,
    String? categoryColorName,
    bool? isVisible,
  }) {
    return CamCategoryEntry(
      categoryName: categoryName ?? this.categoryName,
      categoryTitle: categoryTitle ?? this.categoryTitle,
      categoryColorName: categoryColorName ?? this.categoryColorName,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}
