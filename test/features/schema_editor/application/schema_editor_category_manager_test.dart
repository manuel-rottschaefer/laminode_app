import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SchemaEditorCategoryManager', () {
    final tCategory = CamCategoryEntry(
      categoryName: 'test_cat',
      categoryTitle: 'Test Category',
      categoryColorName: 'red',
    );

    test('addCategory should add a category to the schema', () {
      final notifier = container.read(schemaEditorProvider.notifier);

      notifier.addCategory(tCategory);

      final state = container.read(schemaEditorProvider);
      expect(state.schema.categories.contains(tCategory), true);
    });

    test(
      'updateCategory should update existing category and its references in parameters',
      () {
        final notifier = container.read(schemaEditorProvider.notifier);
        notifier.addCategory(tCategory);

        final tParam = CamParamEntry(
          paramName: 'test_param',
          paramTitle: 'Test Param',
          paramDescription: 'Desc',
          quantity: const ParamQuantity(
            quantityName: 'length',
            quantityUnit: 'mm',
            quantitySymbol: 'mm',
            quantityType: QuantityType.numeric,
          ),
          category: tCategory,
          value: 1.0,
        );
        notifier.addParameter(tParam);

        final updatedCategory = tCategory.copyWith(categoryTitle: 'Updated');
        notifier.updateCategory(tCategory.categoryName, updatedCategory);

        final state = container.read(schemaEditorProvider);
        expect(
          state.schema.categories.any((c) => c.categoryTitle == 'Updated'),
          true,
        );

        final param = state.schema.availableParameters.firstWhere(
          (p) => p.paramName == 'test_param',
        );
        expect(param.category.categoryTitle, 'Updated');
      },
    );

    test(
      'deleteCategory should remove category and move its parameters to default',
      () {
        final notifier = container.read(schemaEditorProvider.notifier);
        notifier.addCategory(tCategory);

        final tParam = CamParamEntry(
          paramName: 'test_param',
          paramTitle: 'Test Param',
          paramDescription: 'Desc',
          quantity: const ParamQuantity(
            quantityName: 'length',
            quantityUnit: 'mm',
            quantitySymbol: 'mm',
            quantityType: QuantityType.numeric,
          ),
          category: tCategory,
          value: 1.0,
        );
        notifier.addParameter(tParam);

        notifier.deleteCategory(tCategory.categoryName);

        final state = container.read(schemaEditorProvider);
        expect(
          state.schema.categories.any(
            (c) => c.categoryName == tCategory.categoryName,
          ),
          false,
        );

        final param = state.schema.availableParameters.firstWhere(
          (p) => p.paramName == 'test_param',
        );
        expect(param.category.categoryName, 'default');
      },
    );

    test('toggleCategoryVisibility should flip isVisible flag', () {
      final notifier = container.read(schemaEditorProvider.notifier);
      notifier.addCategory(tCategory);

      // Initial is true usually
      notifier.toggleCategoryVisibility(tCategory.categoryName);

      var state = container.read(schemaEditorProvider);
      var cat = state.schema.categories.firstWhere(
        (c) => c.categoryName == tCategory.categoryName,
      );
      expect(cat.isVisible, false);

      notifier.toggleCategoryVisibility(tCategory.categoryName);
      state = container.read(schemaEditorProvider);
      cat = state.schema.categories.firstWhere(
        (c) => c.categoryName == tCategory.categoryName,
      );
      expect(cat.isVisible, true);
    });

    test('setAllCategoriesVisibility should update all categories', () {
      final notifier = container.read(schemaEditorProvider.notifier);
      notifier.addCategory(tCategory);

      notifier.setAllCategoriesVisibility(false);

      final state = container.read(schemaEditorProvider);
      for (var cat in state.schema.categories) {
        expect(cat.isVisible, false);
      }
    });

    test('selectCategory should update selectedCategory in state', () {
      final notifier = container.read(schemaEditorProvider.notifier);

      notifier.selectCategory(tCategory);

      final state = container.read(schemaEditorProvider);
      expect(state.selectedCategory, tCategory);

      notifier.selectCategory(null);
      expect(container.read(schemaEditorProvider).selectedCategory, null);
    });
  });
}
