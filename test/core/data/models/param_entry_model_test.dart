import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/data/models/param_entry_model.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';

import '../../../helpers/fixture_reader.dart';
import '../../../helpers/test_models.dart';

void main() {
  final tParamModel = TestModels.tParamModel;

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(
        fixture('param_entry.json'),
      );
      // act
      final result = CamParamEntryModel.fromJson(jsonMap);
      // assert
      expect(result.paramName, tParamModel.paramName);
      expect(result.value, tParamModel.value);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tParamModel.toJson();
      // assert
      expect(result['name'], tParamModel.paramName);
      expect(result['value'], tParamModel.value);
    });
  });

  group('toEntity', () {
    test('should return a valid entity', () {
      // act
      final result = tParamModel.toEntity();
      // assert
      expect(result, isA<CamParamEntry>());
      expect(result.paramName, tParamModel.paramName);
    });
  });
}
