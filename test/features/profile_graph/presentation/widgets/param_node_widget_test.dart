import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/presentation/widgets/param_node_widget.dart';

void main() {
  final category = CamCategoryEntry(
    categoryName: 'Speed',
    categoryTitle: 'Speed Settings',
    categoryColorName: 'blue',
  );

  const quantity = ParamQuantity(
    quantityName: 'speed',
    quantityUnit: 'mm/s',
    quantitySymbol: 'v',
    quantityType: QuantityType.numeric,
  );

  final param = CamParamEntry(
    paramName: 'speed_print',
    paramTitle: 'Print Speed',
    category: category,
    value: '60',
    paramDescription: 'Speed of printing',
    quantity: quantity,
  );

  final node = ParamGraphNode(
    id: 'speed_print',
    label: 'Print Speed',
    parameter: param,
    hasChildren: true,
  );

  testWidgets('ParamNodeWidget builds correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ParamNodeWidget(node: node)),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify CustomPaint is present (the shape)
    expect(find.byType(CustomPaint), findsWidgets);

    // Verify Text is present (from NodeTitle)
    expect(
      find.text('Print Speed'),
      findsNothing,
    ); // It's split into lines by logic, might not match full text exactly if broken up
    expect(find.text('Print'), findsOneWidget); // Likely split
    expect(find.text('Speed'), findsOneWidget);
  });

  testWidgets('ParamNodeWidget handles tap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ParamNodeWidget(node: node, onTap: () => tapped = true),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ParamNodeWidget));
    expect(tapped, true);
  });

  testWidgets('ParamNodeWidget shows integrated action buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 500,
                height: 500,
                child: ParamNodeWidget(node: node),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check for integrated action buttons (Lock and Branching)
    expect(find.byIcon(Icons.lock_open_rounded), findsOneWidget);
    expect(find.byIcon(Icons.call_split_rounded), findsOneWidget);
  });
}
