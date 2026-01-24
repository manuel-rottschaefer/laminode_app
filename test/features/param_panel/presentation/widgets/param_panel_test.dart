import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_panel.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_list_item.dart';
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
  quantityType: QuantityType.numeric,
);

final testCategory = CamCategoryEntry(
  categoryName: 'extrusion',
  categoryTitle: 'Extrusion',
  categoryColorName: 'blue',
);

void main() {
  late FakeSchemaShopNotifier fakeSchemaShopNotifier;

  setUp(() {
    fakeSchemaShopNotifier = FakeSchemaShopNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        schemaShopProvider.overrideWith((ref) => fakeSchemaShopNotifier),
      ],
      child: const MaterialApp(home: Scaffold(body: ParamPanel())),
    );
  }

  testWidgets('should display message when no schema is active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('No parameters available in schema.'), findsOneWidget);
  });

  testWidgets('should display parameters from schema', (
    WidgetTester tester,
  ) async {
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

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Test Parameter'), findsOneWidget);
    expect(find.byType(ParamListItem), findsOneWidget);
  });

  testWidgets('should filter parameters when searching', (
    WidgetTester tester,
  ) async {
    final param1 = CamParamEntry(
      paramName: 'p1',
      paramTitle: 'Apple',
      quantity: testParamQuantity,
      category: testCategory,
      value: 1.0,
    );
    final param2 = CamParamEntry(
      paramName: 'p2',
      paramTitle: 'Banana',
      quantity: testParamQuantity,
      category: testCategory,
      value: 1.0,
    );

    fakeSchemaShopNotifier.setSchema(
      CamSchemaEntry(
        schemaName: 'Test',
        categories: [],
        availableParameters: [param1, param2],
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);

    // Enter search text
    await tester.enterText(
      find.descendant(
        of: find.byType(LamiSearch),
        matching: find.byType(TextField),
      ),
      'app',
    );
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);
  });
}
