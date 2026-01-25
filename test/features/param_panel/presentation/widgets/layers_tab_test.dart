import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/tabs/layers_tab.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_stack_provider.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_stack_info.dart';
import 'package:laminode_app/core/theme/app_colors.dart';

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

  testWidgets('LayersTab should resolve colors correctly', (tester) async {
    final stackInfo = ParamStackInfo(
      paramName: 'test_param',
      contributions: [
        const ParamLayerContribution(
          layerName: 'Base',
          valueDisplay: '1.0',
          isBase: true,
        ),
        const ParamLayerContribution(
          layerName: 'Override',
          valueDisplay: '2.0',
          layerCategory: 'red', // Explicit color name
          isOverride: true,
        ),
        const ParamLayerContribution(
          layerName: 'Category Override',
          valueDisplay: '3.0',
          layerCategory: 'extrusion', // Category name, should fallback to param color (blue)
          isOverride: true,
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paramStackProvider('test_param').overrideWithValue(stackInfo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: LayersTab(param: testParam),
          ),
        ),
      ),
    );

    // Verify 'red' override uses red color
    final redOverrideFinder = find.ancestor(
      of: find.text('Override'),
      matching: find.byType(Container),
    );
    final redContainer = tester.widget<Container>(redOverrideFinder.first);
    expect((redContainer.decoration as BoxDecoration).color, LamiColor.red.value.withValues(alpha: 0.05));

    // Verify 'extrusion' (category) override uses fallback param color (blue)
    final catOverrideFinder = find.ancestor(
      of: find.text('Category Override'),
      matching: find.byType(Container),
    );
    final catContainer = tester.widget<Container>(catOverrideFinder.first);
    expect((catContainer.decoration as BoxDecoration).color, LamiColor.blue.value.withValues(alpha: 0.1)); // isTop is true for last one in reversed list? reversed in build.
  });
}
