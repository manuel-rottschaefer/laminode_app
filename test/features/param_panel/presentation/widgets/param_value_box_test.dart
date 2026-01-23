import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_value_box.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';

class MockParamPanelNotifier extends Notifier<ParamPanelState> implements ParamPanelNotifier {
  final ParamPanelState initialState;
  MockParamPanelNotifier(this.initialState);

  @override
  ParamPanelState build() => initialState;

  String? lastToggledParam;
  @override
  void toggleLock(String paramName) {
    lastToggledParam = paramName;
  }

  String? lastUpdatedParam;
  dynamic lastUpdatedValue;
  @override
  void updateParamValue(String paramName, dynamic value) {
    lastUpdatedParam = paramName;
    lastUpdatedValue = value;
  }

  @override
  void setSearchQuery(String query) {}
  @override
  void toggleExpansion(String paramName) {}
  @override
  void resetParamValue(String paramName) {}
}

void main() {
  late ParamPanelItem testItem;
  late MockParamPanelNotifier mockNotifier;

  setUp(() {
    testItem = ParamPanelItem(
      param: CamParamEntry(
        paramName: 'test_param',
        paramTitle: 'Test Param',
        value: 10.0,
        quantity: const ParamQuantity(
          quantityName: 'Length',
          quantityUnit: 'mm',
          quantitySymbol: 'L',
          quantityType: QuantityType.numeric,
        ),
        category: const TestCategory(),
      ),
      state: ParamItemState.schema,
    );

    mockNotifier = MockParamPanelNotifier(ParamPanelState(items: [testItem]));
  });

  testWidgets('ParamValueBox displays value and toggles lock', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [paramPanelProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          home: Scaffold(body: ParamValueBox(item: testItem)),
        ),
      ),
    );

    expect(find.text('10.0'), findsAtLeast(1));

    final lockIcon = find.byIcon(Icons.lock_open_rounded);
    expect(lockIcon, findsOneWidget);

    await tester.tap(lockIcon);
    await tester.pump();

    expect(mockNotifier.lastToggledParam, 'test_param');
  });

  testWidgets('ParamValueBox updates value on submission', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [paramPanelProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          home: Scaffold(body: ParamValueBox(item: testItem)),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '20.0');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(mockNotifier.lastUpdatedParam, 'test_param');
  });
}

class TestCategory extends CamParamCategory {
  const TestCategory() : super(categoryName: 'test', categoryTitle: 'Test', categoryColorName: 'blue');
}
