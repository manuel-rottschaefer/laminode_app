import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/presentation/widgets/hub_node_widget.dart';
import 'package:laminode_app/features/profile_graph/presentation/widgets/root_node_widget.dart';

void main() {
  group('RootNodeWidget', () {
    const node = RootGraphNode(
      id: 'root',
      label: 'Root',
    );

    testWidgets('should build correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: RootNodeWidget(node: node)),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Root'), findsOneWidget);
    });

    testWidgets('should handle tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RootNodeWidget(
                node: node,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RootNodeWidget));
      expect(tapped, true);
    });
  });

  group('HubNodeWidget', () {
    final category = CamCategoryEntry(
      categoryName: 'cat1',
      categoryTitle: 'Category 1',
      categoryColorName: 'blue',
    );

    final node = HubGraphNode(
      id: 'cat1',
      label: 'Category 1',
      category: category,
    );

    testWidgets('should build correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: HubNodeWidget(node: node)),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text('Category 1'), findsOneWidget);
    });

     testWidgets('should handle tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HubNodeWidget(
                node: node,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(HubNodeWidget));
      expect(tapped, true);
    });
  });
}
