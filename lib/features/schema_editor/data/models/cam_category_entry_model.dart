import 'package:laminode_app/features/schema_editor/domain/entities/cam_category_entry.dart';

class CamCategoryEntryModel extends CamCategoryEntry {
  CamCategoryEntryModel({required super.categoryName});

  factory CamCategoryEntryModel.fromJson(Map<String, dynamic> json) {
    return CamCategoryEntryModel(categoryName: json['categoryName']);
  }

  Map<String, dynamic> toJson() {
    return {'categoryName': categoryName};
  }
}
