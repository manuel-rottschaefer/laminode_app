import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/repositories/layer_panel_repository.dart';

class MockLayerPanelRepository implements LayerPanelRepository {
  List<LamiLayerEntry> _layers = [];

  @override
  void setLayers(List<LamiLayerEntry> layers) {
    _layers = layers;
  }

  @override
  List<LamiLayerEntry> getLayers() => _layers;

  @override
  void updateLayer(int index, LamiLayerEntry layer) {
    if (index >= 0 && index < _layers.length) {
      _layers[index] = layer;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSchemaShopNotifier extends StateNotifier<SchemaShopState>
    implements SchemaShopNotifier {
  FakeSchemaShopNotifier() : super(SchemaShopState());

  void setSchema(CamSchemaEntry schema) {
    state = state.copyWith(activeSchema: schema);
  }

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
}

void main() {
  group('Layer Editing Integration Tests', () {
    late ProviderContainer container;
    late MockLayerPanelRepository mockRepo;
    late FakeSchemaShopNotifier fakeSchema;

    final testCategory = CamCategoryEntry(
      categoryName: 'test_cat',
      categoryTitle: 'Test Category',
      categoryColorName: 'blue',
    );

    const paramName = 'speed';
    final testParam = CamParamEntry(
      paramName: paramName,
      paramTitle: 'Speed',
      quantity: const ParamQuantity(
        quantityName: 'Speed',
        quantityUnit: 'mm/s',
        quantitySymbol: 'v',
        quantityType: QuantityType.numeric,
      ),
      category: testCategory,
      value: 50.0,
    );

    final testSchema = CamSchemaEntry(
      schemaName: 'Test Schema',
      availableParameters: [testParam],
      categories: [testCategory],
    );

    setUp(() {
      mockRepo = MockLayerPanelRepository();
      fakeSchema = FakeSchemaShopNotifier();
      fakeSchema.setSchema(testSchema);

      container = ProviderContainer(
        overrides: [
          layerPanelRepositoryProvider.overrideWithValue(mockRepo),
          schemaShopProvider.overrideWith((ref) => fakeSchema),
        ],
      );

      // Initialize layers
      mockRepo.setLayers([
        LamiLayerEntry(
          layerName: 'Layer 1',
          layerAuthor: 'me',
          layerDescription: '',
          layerCategory: 'test_cat',
          parameters: [],
        ),
        LamiLayerEntry(
          layerName: 'Layer 2',
          layerAuthor: 'me',
          layerDescription: '',
          layerCategory: 'test_cat',
          parameters: [],
        ),
      ]);
    });

    test(
      'should allow independent editing of the same parameter in different layers',
      () {
        final notifier = container.read(paramPanelProvider.notifier);

        // 1. Select Layer 1 and edit to 100
        notifier.setSelectedLayerIndex(paramName, 0);
        notifier.updateParamValue(paramName, '100');

        // Check layer state
        expect(
          container.read(layerPanelProvider).layers[0].parameters?.first.value,
          100.0,
        );
        expect(
          container.read(layerPanelProvider).layers[1].parameters,
          isEmpty,
        );

        // 2. Select Layer 2 and edit to 200
        notifier.setSelectedLayerIndex(paramName, 1);

        // View should show default/base value initially
        final currentItem = container
            .read(paramPanelItemsProvider)
            .firstWhere((i) => i.param.paramName == paramName);
        expect(currentItem.param.value, 50.0);

        notifier.updateParamValue(paramName, '200');

        // Check layer states
        expect(
          container.read(layerPanelProvider).layers[0].parameters?.first.value,
          100.0,
        );
        expect(
          container.read(layerPanelProvider).layers[1].parameters?.first.value,
          200.0,
        );

        // 3. Switch back to Layer 1
        notifier.setSelectedLayerIndex(paramName, 0);
        final finalItem = container
            .read(paramPanelItemsProvider)
            .firstWhere((i) => i.param.paramName == paramName);
        expect(finalItem.param.value, 100.0);
      },
    );
  });
}
