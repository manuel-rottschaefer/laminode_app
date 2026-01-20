import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/profile_editor/data/models/profile_model.dart';
import 'package:laminode_app/core/domain/entities/lami_profile.dart';

import '../../../../helpers/fixture_reader.dart';

void main() {
  final tProfileModel = ProfileModel(
    profileName: 'Default Fine Profile',
    layers: [],
  );

  group('fromJson', () {
    test('should return a valid model when the JSON is correct', () {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('profile.json'));
      // act
      final result = ProfileModel.fromJson(jsonMap, []);
      // assert
      expect(result.profileName, tProfileModel.profileName);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // act
      final result = tProfileModel.toJson();
      // assert
      expect(result['profileName'], tProfileModel.profileName);
    });
  });

  group('toEntity', () {
    test('should return a valid entity', () {
      // act
      final result = tProfileModel.toEntity();
      // assert
      expect(result, isA<LamiProfile>());
      expect(result.profileName, tProfileModel.profileName);
    });
  });
}
