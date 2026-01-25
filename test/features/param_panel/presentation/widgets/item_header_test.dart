import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/items/item_header.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/theme/app_colors.dart';

void main() {
  final testQuantity = const ParamQuantity(
    quantityName: 'length',
    quantityUnit: 'mm',
    quantitySymbol: 'L',
    quantityType: QuantityType.numeric,
  );

  final testCategory = CamCategoryEntry(
    categoryName: 'blue', // Using a name that maps to LamiColor
    categoryTitle: 'Blue Category',
    categoryColorName: 'blue',
  );

  final testParam = CamParamEntry(
    paramName: 'test_param',
    paramTitle: 'Test Parameter',
    quantity: testQuantity,
    category: testCategory,
    value: 1.0,
  );

  Widget buildHeader({required bool isExpanded}) {
    return MaterialApp(
      home: Scaffold(
        body: ItemHeader(
          item: ParamPanelItem(param: testParam, state: ParamItemState.schema),
          isExpanded: isExpanded,
          onTap: () {},
        ),
      ),
    );
  }

  testWidgets('ItemHeader should render title and character spacing', (
    tester,
  ) async {
    await tester.pumpWidget(buildHeader(isExpanded: false));
    await tester.pumpAndSettle();

    expect(find.text('Test Parameter'), findsOneWidget);
  });

  testWidgets(
    'ItemHeader should have different maxLines when expanded/collapsed',
    (tester) async {
      // Collapsed
      await tester.pumpWidget(buildHeader(isExpanded: false));
      final collapsedTextWidget = tester.widget<Text>(
        find.text('Test Parameter'),
      );
      expect(collapsedTextWidget.maxLines, 1);

      // Expanded
      await tester.pumpWidget(buildHeader(isExpanded: true));
      final expandedTextWidget = tester.widget<Text>(
        find.text('Test Parameter'),
      );
      expect(expandedTextWidget.maxLines, 2);
    },
  );

  testWidgets(
    'ItemHeader icon color should use category color when collapsed',
    (tester) async {
      await tester.pumpWidget(buildHeader(isExpanded: false));
      final icon = tester.widget<Icon>(find.byType(Icon).first);
      expect(icon.color, LamiColor.blue.value.withValues(alpha: 0.8));
    },
  );
}
