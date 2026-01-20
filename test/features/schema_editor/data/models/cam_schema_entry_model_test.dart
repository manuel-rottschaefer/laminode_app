import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/data/models/cam_schema_entry_model.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';

import '../../../../helpers/fixture_reader.dart';
import '../../../../helpers/test_models.dart';

void main() {
  final tCategoryModel = TestModels.tCategoryModel;
  final tCategory = tCategoryModel.toEntity();

  final tParamModel = TestModels.tParamModel;

  final tSchemaModel = CamSchemaEntryModel(
    schemaName: 'fdm_basic_schema',
    categories: [tCategoryModel],
    availableParameters: [tParamModel],
  );

  final tSchemaEntry = CamSchemaEntry(
    schemaName: 'fdm_basic_schema',
    categories: [tCategory],
    availableParameters: [tParamModel.toEntity()],
  );

  group('CamSchemaEntryModel', () {
    test('should be a subclass of its entity (via toEntity)', () {
      // assert
      final result = tSchemaModel.toEntity();
      expect(result.schemaName, tSchemaEntry.schemaName);
      expect(result.categories.length, tSchemaEntry.categories.length);
      expect(
        result.availableParameters.length,
        tSchemaEntry.availableParameters.length,
      );
    });

    test('should return a valid model from JSON', () {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(
        fixture('cam_schema_entry.json'),
      );
      // act
      final result = CamSchemaEntryModel.fromJson(jsonMap);
      // assert
      expect(result.schemaName, tSchemaModel.schemaName);
      expect(
        result.categories.first.categoryName,
        tSchemaModel.categories.first.categoryName,
      );
    });

    test('should return a JSON map containing the proper data', () {
      // act
      final result = tSchemaModel.toJson();
      // assert
      expect(result['schemaName'], 'fdm_basic_schema');
      expect(result['categories'], isA<List>());
      expect(result['availableParameters'], isA<List>());
    });

    test('fromEntity should create a valid model', () {
      // act
      final result = CamSchemaEntryModel.fromEntity(tSchemaEntry);
      // assert
      expect(result.schemaName, tSchemaEntry.schemaName);
      expect(result.categories.length, tSchemaEntry.categories.length);
    });
  });
}
