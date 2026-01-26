import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/schema_editor/data/repositories/schema_editor_repository_impl.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';

void main() {
  late SchemaEditorRepositoryImpl repository;
  late Directory tempDir;

  setUp(() async {
    repository = SchemaEditorRepositoryImpl();
    tempDir = await Directory.systemTemp.createTemp('laminode_test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('SchemaEditorRepositoryImpl', () {
    final tSchema = CamSchemaEntry(
      schemaName: 'test_schema',
      categories: [
        CamCategoryEntry(
          categoryName: 'cat',
          categoryTitle: 'Cat',
          categoryColorName: 'red',
        ),
      ],
      availableParameters: [
        CamParamEntry(
          paramName: 'p',
          paramTitle: 'P',
          quantity: const ParamQuantity(
            quantityName: 'length',
            quantityUnit: 'mm',
            quantitySymbol: 'L',
            quantityType: QuantityType.numeric,
          ),
          category: CamCategoryEntry(
            categoryName: 'cat',
            categoryTitle: 'Cat',
            categoryColorName: 'red',
          ),
          value: 0,
        ),
      ],
    );

    test('should export schema to file', () async {
      // arrange
      final filePath = '${tempDir.path}/schema.json';
      // act
      await repository.exportSchema(tSchema, filePath);
      // assert
      final file = File(filePath);
      expect(await file.exists(), true);
      final content = await file.readAsString();
      final json = jsonDecode(content);
      expect(json['name'], 'test_schema');
    });

    test('should import schema from file', () async {
      // arrange
      final filePath = '${tempDir.path}/import.json';
      final jsonString = jsonEncode({
        'name': 'imported',
        'categories': [
          {'name': 'c', 'title': 'C', 'color': 'b'},
        ],
        'availableParameters': [
          {
            'name': 'p',
            'title': 'P',
            'quantity': {
              'quantityName': 'n',
              'quantityUnit': 'u',
              'quantitySymbol': 's',
            },
            'category': {'name': 'c', 'title': 'C', 'color': 'b'},
            'value': 10,
          },
        ],
      });
      await File(filePath).writeAsString(jsonString);

      // act
      final result = await repository.importSchema(filePath);

      // assert
      expect(result?.schemaName, 'imported');
      expect(result?.categories.length, 1);
    });
  });
}
