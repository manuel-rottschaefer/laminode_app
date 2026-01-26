import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/data/models/cam_category_entry_model.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

import '../../../helpers/fixture_reader.dart';
import '../../../helpers/test_models.dart';

void main() {
  final tCategoryModel = TestModels.tCategoryModel;

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(
        fixture('cam_category_entry.json'),
      );
      // act
      final result = CamCategoryEntryModel.fromJson(jsonMap);
      // assert
      expect(result.categoryName, tCategoryModel.categoryName);
      expect(result.categoryTitle, tCategoryModel.categoryTitle);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tCategoryModel.toJson();
      // assert
      expect(result['name'], tCategoryModel.categoryName);
    });
  });

  group('toEntity', () {
    test('should return a valid entity', () {
      // act
      final result = tCategoryModel.toEntity();
      // assert
      expect(result, isA<CamCategoryEntry>());
      expect(result.categoryName, tCategoryModel.categoryName);
    });
  });
}
