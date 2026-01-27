import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

void main() {
  group('CamSchemaEntry', () {
    test('should be initialized correctly', () {
      final entry = CamSchemaEntry(
        schemaName: 'Test',
        categories: [
          CamCategoryEntry(
            categoryName: 'cat',
            categoryTitle: 'Cat',
            categoryColorName: 'blue',
          ),
        ],
        availableParameters: [],
      );

      expect(entry.schemaName, 'Test');
      expect(entry.categories.length, 1);
    });
  });
}
