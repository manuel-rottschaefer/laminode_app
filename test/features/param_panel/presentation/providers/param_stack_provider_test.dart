import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_stack_provider.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/profile_manager/domain/repositories/profile_repository.dart';
import 'package:laminode_app/features/schema_shop/domain/repositories/schema_shop_repository.dart';

// Helper to create basic param
CamParamEntry _createParam(String name, dynamic value, {bool edited = false}) {
  return CamParamEntry(
    paramName: name,
    paramTitle: name,
    quantity: const ParamQuantity(
      quantityName: 'q',
      quantityUnit: 'u',
      quantitySymbol: 's',
      quantityType: QuantityType.numeric,
    ),
    category: CamCategoryEntry(
      categoryName: 'c',
      categoryTitle: 'c',
      categoryColorName: 'blue',
    ),
    value: value,
    isEdited: edited,
  );
}

// -----------------------------------------------------------------------------
// Mocks
// -----------------------------------------------------------------------------

class MockProfileRepository implements ProfileRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSchemaShopRepository implements SchemaShopRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ProfileManagerNotifierMock extends ProfileManagerNotifier {
  ProfileManagerNotifierMock(Ref ref) : super(MockProfileRepository(), ref) {
    // Set initial state for test
    state = ProfileManagerState(
      currentProfile: ProfileEntity(
        name: 'Test Profile',
        application: ProfileApplication.empty(),
        layers: [
          LamiLayerEntry(
            layerName: 'Layer 1',
            layerAuthor: 'A',
            layerDescription: 'D',
            parameters: [_createParam('speed', 20, edited: true)],
          ),
          LamiLayerEntry(
            layerName: 'Layer 2', // No override
            layerAuthor: 'A',
            layerDescription: 'D',
            parameters: [_createParam('speed', 20, edited: false)],
          ),
          LamiLayerEntry(
            layerName: 'Layer 3',
            layerAuthor: 'A',
            layerDescription: 'D',
            parameters: [_createParam('speed', 30, edited: true)],
          ),
        ],
      ),
    );
  }
}

class SchemaShopNotifierMock extends SchemaShopNotifier {
  SchemaShopNotifierMock() : super(MockSchemaShopRepository()) {
    // Set initial state
    state = SchemaShopState(
      activeSchema: CamSchemaEntry(
        schemaName: 'TestSchema',
        categories: [],
        availableParameters: [
          _createParam('speed', 10), // Base default effectively
        ],
      ),
    );
  }

  @override
  Future<void> refreshInstalled() async {
    // No-op to prevent repository calls during init
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------

void main() {
  group('ParamStackProvider', () {
    test('Correctly aggregates Schema (Base) + Profile Layers (Overrides)', () {
      final container = ProviderContainer(
        overrides: [
          profileManagerProvider.overrideWith(
            (ref) => ProfileManagerNotifierMock(ref),
          ),
          schemaShopProvider.overrideWith((ref) => SchemaShopNotifierMock()),
        ],
      );

      // Verify Provider state
      // We expect: Base (Schema Default) -> Layer 1 (Override) -> Layer 2 (Skipped/Inherit) -> Layer 3 (Override)

      final stack = container.read(paramStackProvider('speed'));

      // Expected structure:
      // 0: Base (10)
      // 1: Layer 1 (20) - isOverride: true
      // 2: Layer 3 (30) - isOverride: true
      // Layer 2 should be skipped because isEdited=false

      expect(
        stack.contributions.length,
        3,
        reason: 'Should have 3 contributions (Base + Layer1 + Layer3)',
      );

      // 1. Base (Schema)
      final base = stack.contributions[0];
      expect(base.isBase, true);
      expect(
        base.layerName,
        'Base Profile (Schema Default)',
      ); // Base layer used fixed name in implementation
      expect(
        base.valueDisplay,
        '0',
      ); // Fallback is 0 because defaultValue is null in mock

      // 2. Layer 1 (Override)
      final l1 = stack.contributions[1];
      expect(l1.isBase, false);
      expect(l1.isOverride, true);
      expect(l1.layerName, 'Layer 1');
      expect(l1.valueDisplay, '20');

      // 3. Layer 3 (Override)
      final l3 = stack.contributions[2];
      expect(l3.isBase, false);
      expect(l3.isOverride, true);
      expect(l3.layerName, 'Layer 3');
      expect(l3.valueDisplay, '30');
    });

    test('Handling missing Active Schema', () {
      final container = ProviderContainer(
        overrides: [
          profileManagerProvider.overrideWith(
            (ref) => ProfileManagerNotifierMock(ref),
          ),
          schemaShopProvider.overrideWith(
            (ref) =>
                SchemaShopNotifierMock()
                  ..state = SchemaShopState(activeSchema: null),
          ),
        ],
      );

      final stack = container.read(paramStackProvider('speed'));
      // If no schema, base might likely be derived from nothing or skipped?

      expect(
        stack.contributions.length,
        2,
      ); // Layer 1, Layer 3. No base because no schema default to match.

      final layer1 = stack.contributions.firstWhere(
        (c) => c.layerName == 'Layer 1',
      );
      expect(layer1.valueDisplay, '20');
    });
  });
}
