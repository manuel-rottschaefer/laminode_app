import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_tab.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/tabs/value_tab.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';

class MockParamPanelNotifier extends Notifier<ParamPanelState>
    implements ParamPanelNotifier {
  final ParamPanelState initialState;
  MockParamPanelNotifier(this.initialState);

  @override
  ParamPanelState build() => initialState;

  @override
  void setSearchQuery(String query) {}

  @override
  void navigateToParam(String paramName) {
    state = state.copyWith(expandedParamName: paramName);
  }

  @override
  void goBack() {}

  @override
  void updateFocusedParamValue(dynamic value) {}

  @override
  void toggleExpansion(String paramName) {}

  @override
  void toggleBranching(String paramName) {}

  @override
  void setBranchedParamNames(Set<String> names) {}

  @override
  void toggleLock(String paramName) {
    lastToggledParam = paramName;
  }

  @override
  void updateParamValue(String paramName, dynamic value) {
    lastUpdatedParam = paramName;
    lastUpdatedValue = value;
  }

  @override
  void setSelectedLayerIndex(String paramName, int layerIndex) {}

  @override
  void setSelectedTab(String paramName, ParamTab tab) {}

  @override
  void resetParamValue(String paramName) {}

  @override
  void clearFocus() {
    state = state.copyWith(clearExpansion: true, clearFocus: true, history: []);
  }

  String? lastToggledParam;

  String? lastUpdatedParam;
  dynamic lastUpdatedValue;
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

    mockNotifier = MockParamPanelNotifier(ParamPanelState());
  });

  testWidgets('ValueTab displays value and toggles lock', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [paramPanelProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          home: Scaffold(body: ValueTab(item: testItem)),
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

  testWidgets('ValueTab updates value on submission', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [paramPanelProvider.overrideWith(() => mockNotifier)],
        child: MaterialApp(
          home: Scaffold(body: ValueTab(item: testItem)),
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
  const TestCategory()
    : super(
        categoryName: 'test',
        categoryTitle: 'Test',
        categoryColorName: 'blue',
      );
}
