import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/tabs/info_tab.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/presentation/widgets/lami_colored_badge.dart';

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

  CamParamEntry createParam(String name) {
    return CamParamEntry(
      paramName: name,
      paramTitle: 'Title',
      quantity: testQuantity,
      category: testCategory,
      value: 1.0,
    );
  }

  testWidgets('InfoTab should use grey badge for type', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfoTab(param: createParam('test')),
        ),
      ),
    );

    final badge = tester.widget<LamiColoredBadge>(find.byType(LamiColoredBadge));
    expect(badge.color, Colors.grey.withValues(alpha: 0.5));
  });

  testWidgets('InfoTab should have larger font for short names', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfoTab(param: createParam('short_name')),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('short_name'));
    expect(text.style?.fontSize, 12);
  });

  testWidgets('InfoTab should have smaller font for long names', (tester) async {
    const longName = 'this_is_a_very_long_parameter_name_indeed';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfoTab(param: createParam(longName)),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text(longName));
    expect(text.style?.fontSize, 10);
    expect(text.maxLines, 2);
  });
}
