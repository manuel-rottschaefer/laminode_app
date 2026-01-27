import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('SchemaEditorParameterManager', () {
    final tCategory = CamCategoryEntry(
      categoryName: 'default',
      categoryTitle: 'Default',
      categoryColorName: 'blue',
    );

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

    test('addParameter should add a parameter to the schema', () {
      final notifier = container.read(schemaEditorProvider.notifier);

      notifier.addParameter(tParam);

      final state = container.read(schemaEditorProvider);
      expect(state.schema.availableParameters.contains(tParam), true);
    });

    test(
      'updateParameter should update existing parameter and sync selection',
      () {
        final notifier = container.read(schemaEditorProvider.notifier);
        notifier.addParameter(tParam);
        notifier.selectParameter(tParam);

        final updatedParam = tParam.copyWith(paramTitle: 'Updated Title');
        notifier.updateParameter(tParam.paramName, updatedParam);

        final state = container.read(schemaEditorProvider);
        expect(
          state.schema.availableParameters.any(
            (p) => p.paramTitle == 'Updated Title',
          ),
          true,
        );
        expect(state.selectedParameter?.paramTitle, 'Updated Title');
      },
    );

    test(
      'deleteParameter should remove parameter and clear selection if it was selected',
      () {
        final notifier = container.read(schemaEditorProvider.notifier);
        notifier.addParameter(tParam);
        notifier.selectParameter(tParam);

        notifier.deleteParameter(tParam.paramName);

        final state = container.read(schemaEditorProvider);
        expect(
          state.schema.availableParameters.any(
            (p) => p.paramName == tParam.paramName,
          ),
          false,
        );
        expect(state.selectedParameter, null);
      },
    );

    test('setParameterSearchQuery should update search query in state', () {
      final notifier = container.read(schemaEditorProvider.notifier);

      notifier.setParameterSearchQuery('search term');

      final state = container.read(schemaEditorProvider);
      expect(state.parameterSearchQuery, 'search term');
    });

    test(
      'addChildRelation and removeChildRelation should manage hierarchy',
      () {
        final parentParam = tParam.copyWith(paramName: 'parent');
        final childParam = tParam.copyWith(paramName: 'child');

        final notifier = container.read(schemaEditorProvider.notifier);
        notifier.addParameter(parentParam);
        notifier.addParameter(childParam);

        notifier.addChildRelation('parent', 'child');

        var state = container.read(schemaEditorProvider);
        var p = state.schema.availableParameters.firstWhere(
          (p) => p.paramName == 'parent',
        );
        expect(p.children.any((c) => c.childParamName == 'child'), true);

        notifier.removeChildRelation('parent', 'child');
        state = container.read(schemaEditorProvider);
        p = state.schema.availableParameters.firstWhere(
          (p) => p.paramName == 'parent',
        );
        expect(p.children.any((c) => c.childParamName == 'child'), false);
      },
    );
  });
}
