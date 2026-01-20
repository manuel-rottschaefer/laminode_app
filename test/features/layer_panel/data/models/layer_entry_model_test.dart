import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_panel/data/models/layer_entry_model.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

import '../../../../helpers/fixture_reader.dart';
import '../../../../helpers/test_models.dart';

void main() {
  const tLayerEntryModel = TestModels.tLayerEntryModel;

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(
        fixture('layer_entry.json'),
      );
      // act
      final result = LayerEntryModel.fromJson(jsonMap);
      // assert
      expect(result.layerName, tLayerEntryModel.layerName);
      expect(result.layerDescription, tLayerEntryModel.layerDescription);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tLayerEntryModel.toJson();
      // assert
      final expectedMap = {
        "layerName": "Test Layer",
        "parameters": [],
        "layerAuthor": "Admin",
        "layerDescription": "A test layer description",
        "layerCategory": null,
        "isActive": true,
        "isLocked": false,
      };
      expect(result, expectedMap);
    });
  });

  group('toEntity', () {
    test('should return a valid entity', () {
      // act
      final result = tLayerEntryModel.toEntity();
      // assert
      expect(result, isA<LamiLayerEntry>());
      expect(result.layerName, tLayerEntryModel.layerName);
    });
  });
}
