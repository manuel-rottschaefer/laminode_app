import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_item.dart';

void main() {
  const tEntry = LamiLayerEntry(
    layerName: 'Test Layer',
    layerAuthor: 'Admin',
    layerDescription: 'Description',
    parameters: [],
  );

  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(
        home: Scaffold(body: LayerItem(entry: tEntry, index: 0)),
      ),
    );
  }

  testWidgets('should display layer name', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Test Layer'), findsOneWidget);
    expect(find.textContaining('effective parameters'), findsOneWidget);
  });

  testWidgets('should show action buttons when expanded', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Tap to expand
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    // Icons for Edit and Delete should appear
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
  });
}
