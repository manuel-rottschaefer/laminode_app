import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

class FakeSchemaShopNotifier extends StateNotifier<SchemaShopState>
    implements SchemaShopNotifier {
  FakeSchemaShopNotifier() : super(SchemaShopState());

  @override
  void clearActiveSchema() {}
  @override
  Future<void> fetchPlugins() async {}
  @override
  Future<void> installPlugin(any, any2) async {}
  @override
  Future<void> installManualSchema(any) async {}
  @override
  Future<void> loadSchema(any) async {}
  @override
  Future<void> refreshInstalled() async {}
  @override
  Future<void> uninstallPlugin(any) async {}

  void setSchema(CamSchemaEntry? schema) {
    state = state.copyWith(activeSchema: schema);
  }
}

final testParamQuantity = const ParamQuantity(
  quantityName: 'length',
  quantityUnit: 'mm',
  quantitySymbol: 'L',
);

final testCategory = CamCategoryEntry(
  categoryName: 'extrusion',
  categoryTitle: 'Extrusion',
  categoryColorName: 'blue',
);

void main() {
  group('ParamPanelNotifier', () {
    late ProviderContainer container;
    late FakeSchemaShopNotifier fakeSchemaShopNotifier;

    setUp(() {
      fakeSchemaShopNotifier = FakeSchemaShopNotifier();
      container = ProviderContainer(
        overrides: [
          schemaShopProvider.overrideWith((ref) => fakeSchemaShopNotifier),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be empty if no schema', () {
      final state = container.read(paramPanelProvider);
      expect(state.items, isEmpty);
      expect(state.searchQuery, '');
    });

    test(
      'should show schema items when schema is present and search is empty',
      () {
        final param = CamParamEntry(
          paramName: 'test_param',
          paramTitle: 'Test Parameter',
          quantity: testParamQuantity,
          category: testCategory,
          value: 1.0,
        );

        final schema = CamSchemaEntry(
          schemaName: 'Test Schema',
          categories: [],
          availableParameters: [param],
        );

        fakeSchemaShopNotifier.setSchema(schema);

        final state = container.read(paramPanelProvider);
        expect(state.items.length, 1);
        expect(state.items.first.param.paramName, 'test_param');
        expect(state.items.first.state, ParamItemState.schema);
      },
    );

    test('should show search items when search query matches', () {
      final param1 = CamParamEntry(
        paramName: 'test_param_1',
        paramTitle: 'First Parameter',
        quantity: testParamQuantity,
        category: testCategory,
        value: 1.0,
      );
      final param2 = CamParamEntry(
        paramName: 'test_param_2',
        paramTitle: 'Second Parameter',
        quantity: testParamQuantity,
        category: testCategory,
        value: 2.0,
      );

      final schema = CamSchemaEntry(
        schemaName: 'Test Schema',
        categories: [],
        availableParameters: [param1, param2],
      );

      fakeSchemaShopNotifier.setSchema(schema);

      container.read(paramPanelProvider.notifier).setSearchQuery('first');

      final state = container.read(paramPanelProvider);
      expect(state.items.length, 1);
      expect(state.items.first.param.paramName, 'test_param_1');
      expect(state.items.first.state, ParamItemState.search);
    });

    test('should filter out items that do not match search', () {
      final param1 = CamParamEntry(
        paramName: 'test_param_1',
        paramTitle: 'First Parameter',
        quantity: testParamQuantity,
        category: testCategory,
        value: 1.0,
      );

      final schema = CamSchemaEntry(
        schemaName: 'Test Schema',
        categories: [],
        availableParameters: [param1],
      );

      fakeSchemaShopNotifier.setSchema(schema);

      container.read(paramPanelProvider.notifier).setSearchQuery('xyz');

      final state = container.read(paramPanelProvider);
      expect(state.items, isEmpty);
    });
  });
}
