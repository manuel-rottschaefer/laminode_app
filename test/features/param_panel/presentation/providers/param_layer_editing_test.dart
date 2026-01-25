import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
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

class FakeLayerPanelNotifier extends Notifier<LayerPanelState>
    implements LayerPanelNotifier {
  @override
  LayerPanelState build() {
    return LayerPanelState();
  }

  void setLayers(List<LamiLayerEntry> layers) {
    state = state.copyWith(layers: layers);
  }

  @override
  void addLayer({
    required String name,
    String description = "",
    required String category,
  }) {}
  @override
  void moveLayerDown(int index) {}
  @override
  void moveLayerUp(int index) {}
  @override
  void removeLayer(int index) {}
  @override
  void reorderLayers(int oldIndex, int newIndex) {}
  @override
  void setExpandedIndex(int? index) {}
  @override
  void setSearchQuery(String query) {}
  @override
  void toggleLayerActive(int index) {}
  @override
  void toggleLayerLocked(int index) {}
  @override
  void updateLayer(int index, {String? name, String? description}) {}
  @override
  void updateLayerName(int index, String newName) {}

  @override
  void updateParamValue(int layerIndex, String paramName, dynamic value) {
    final layers = List<LamiLayerEntry>.from(state.layers);
    final layer = layers[layerIndex];
    final params = List<CamParamEntry>.from(layer.parameters ?? []);
    final pIdx = params.indexWhere((p) => p.paramName == paramName);

    final newParam = CamParamEntry(
      paramName: paramName,
      paramTitle: '',
      quantity: const ParamQuantity(
        quantityName: '',
        quantityUnit: '',
        quantitySymbol: '',
        quantityType: QuantityType.numeric,
      ),
      category: CamCategoryEntry(
        categoryName: '',
        categoryTitle: '',
        categoryColorName: '',
      ),
      value: value,
      isEdited: true,
    );

    if (pIdx != -1) {
      params[pIdx] = params[pIdx].copyWith(value: value, isEdited: true);
    } else {
      params.add(newParam);
    }

    layers[layerIndex] = layer.copyWith(parameters: params);
    state = state.copyWith(layers: layers);
  }

  @override
  void resetParamValue(int layerIndex, String paramName) {
    final layers = List<LamiLayerEntry>.from(state.layers);
    final layer = layers[layerIndex];
    final params = List<CamParamEntry>.from(layer.parameters ?? []);
    params.removeWhere((p) => p.paramName == paramName);
    layers[layerIndex] = layer.copyWith(parameters: params);
    state = state.copyWith(layers: layers);
  }
}

void main() {
  group('Param Layer Editing Integration', () {
    late ProviderContainer container;
    late FakeSchemaShopNotifier fakeSchema;
    late FakeLayerPanelNotifier fakeLayers;

    final testCategory = CamCategoryEntry(
      categoryName: 'speed',
      categoryTitle: 'Speed',
      categoryColorName: 'blue',
    );

    final testParamDef = CamParamEntry(
      paramName: 'print_speed',
      paramTitle: 'Print Speed',
      quantity: const ParamQuantity(
        quantityName: 'speed',
        quantityUnit: 'mm/s',
        quantitySymbol: 'v',
        quantityType: QuantityType.numeric,
      ),
      category: testCategory,
      value: 50.0,
    );

    setUp(() {
      fakeSchema = FakeSchemaShopNotifier();
      fakeLayers = FakeLayerPanelNotifier();
      container = ProviderContainer(
        overrides: [
          schemaShopProvider.overrideWith((ref) => fakeSchema),
          layerPanelProvider.overrideWith(() => fakeLayers),
        ],
      );
    });

    test('should independently edit parameter values in different layers', () {
      // 1. Setup Schema
      container.read(schemaShopProvider);
      fakeSchema.setSchema(
        CamSchemaEntry(
          schemaName: 'Test',
          categories: [],
          availableParameters: [testParamDef],
        ),
      );

      // 2. Setup 2 Layers with same category
      container.read(layerPanelProvider);
      final layer1 = LamiLayerEntry(
        layerName: 'Layer 1',
        layerAuthor: 'me',
        layerDescription: '',
        layerCategory: 'speed',
        parameters: [],
      );
      final layer2 = LamiLayerEntry(
        layerName: 'Layer 2',
        layerAuthor: 'me',
        layerDescription: '',
        layerCategory: 'speed',
        parameters: [],
      );
      fakeLayers.setLayers([layer1, layer2]);

      // 3. Select Layer 1 and edit
      container
          .read(paramPanelProvider.notifier)
          .setSelectedLayerIndex('print_speed', 0);
      container
          .read(paramPanelProvider.notifier)
          .updateParamValue('print_speed', 60.0);

      expect(
        container.read(layerPanelProvider).layers[0].parameters?.first.value,
        60.0,
      );
      expect(container.read(layerPanelProvider).layers[1].parameters, isEmpty);

      // 4. Select Layer 2 and edit differently
      container
          .read(paramPanelProvider.notifier)
          .setSelectedLayerIndex('print_speed', 1);
      container
          .read(paramPanelProvider.notifier)
          .updateParamValue('print_speed', 80.0);

      expect(
        container.read(layerPanelProvider).layers[0].parameters?.first.value,
        60.0,
      );
      expect(
        container.read(layerPanelProvider).layers[1].parameters?.first.value,
        80.0,
      );

      // 5. Verify ParamPanel state reflects selected layer
      container
          .read(paramPanelProvider.notifier)
          .setSelectedLayerIndex('print_speed', 0);
      expect(container.read(paramPanelItemsProvider).first.param.value, 60.0);

      container
          .read(paramPanelProvider.notifier)
          .setSelectedLayerIndex('print_speed', 1);
      expect(container.read(paramPanelItemsProvider).first.param.value, 80.0);
    });
  });
}
