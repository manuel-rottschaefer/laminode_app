import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/items/param_list_item.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_tab.dart';
import 'package:laminode_app/core/presentation/widgets/lami_segmented_control.dart';

void main() {
  final testQuantity = const ParamQuantity(
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

  final testParam = CamParamEntry(
    paramName: 'test_param',
    paramTitle: 'Test Parameter',
    quantity: testQuantity,
    category: testCategory,
    value: 1.0,
  );

  final testItem = ParamPanelItem(
    param: testParam,
    state: ParamItemState.schema,
  );

  testWidgets('ParamListItem should expand and show tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ParamListItem(item: testItem)),
        ),
      ),
    );

    // Should see header
    expect(find.text('Test Parameter'), findsOneWidget);

    // Tap to expand
    await tester.tap(find.text('Test Parameter'));
    await tester.pumpAndSettle();

    // Should see segmented control
    expect(find.byType(LamiSegmentedControl<ParamTab>), findsOneWidget);

    // Default tab is Info, should see param name
    expect(find.text('test_param'), findsOneWidget);

    // Switch to Edit tab
    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Value'), findsOneWidget);

    // Switch to Relation tab
    await tester.tap(find.byIcon(Icons.hub_rounded));
    await tester.pumpAndSettle();
    expect(find.text('PARAMETER HIERARCHY'), findsOneWidget);

    // Switch to Layers tab
    await tester.tap(find.byIcon(Icons.layers_rounded));
    await tester.pumpAndSettle();
    expect(find.text('COMPUTED STACK'), findsOneWidget);
  });
}
