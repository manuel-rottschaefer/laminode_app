import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_schema_model.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';

void main() {
  group('PluginSchemaModel', () {
    test('fromJson should return a valid model with categories and parameters', () {
      final Map<String, dynamic> jsonMap = {
        'manifest': {
          'schemaType': 'application',
          'schemaVersion': '1.0.0',
          'schemaAuthors': ['Author'],
          'lastUpdated': '2023-01-01',
          'targetAppName': 'App',
          'targetAppSector': 'FDM',
        },
        'categories': [
          {'name': 'cat1', 'title': 'Category 1', 'color': 'red'},
        ],
        'availableParameters': [
          {
            'name': 'param1',
            'title': 'Parameter 1',
            'description': 'Desc',
            'category': 'cat1',
            'quantity': {
              'name': 'len',
              'unit': 'mm',
              'symbol': 'L',
              'type': 'numeric',
            },
          },
        ],
      };

      final result = PluginSchemaModel.fromJson(jsonMap);

      expect(result.manifest.schemaVersion, '1.0.0');
      expect(result.categories.length, 1);
      expect(result.categories[0].categoryName, 'cat1');
      expect(result.availableParameters.length, 1);
      expect(result.availableParameters[0].paramName, 'param1');
      expect(result.availableParameters[0].category.categoryName, 'cat1');
    });

    test('toEntity should return a valid CamSchemaEntry', () {
      final Map<String, dynamic> jsonMap = {
        'manifest': {
          'schemaType': 'application',
          'schemaVersion': '1.0.0',
          'schemaAuthors': ['Author'],
          'lastUpdated': '2023-01-01',
          'targetAppName': 'App',
        },
        'categories': [],
        'availableParameters': [],
      };

      final model = PluginSchemaModel.fromJson(jsonMap);
      final entity = model.toEntity();

      expect(entity, isA<CamSchemaEntry>());
      expect(entity.schemaName, 'App');
    });
  });
}
