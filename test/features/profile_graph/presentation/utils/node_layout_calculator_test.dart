import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_calculator.dart';

void main() {
  group('NodeLayoutCalculator', () {
    testWidgets('computeHex returns valid layout data', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      final context = tester.element(find.byType(Container));

      final result = NodeLayoutCalculator.computeHex(
        title: 'Speed Layer 0',
        edgeLength: 140.0,
        level: 0,
        cornerRadiusFactor: 0.15,
        titleStyle: const TextStyle(fontSize: 18),
        context: context,
        baseColor: Colors.blue,
        isFocused: false,
        id: 'test_id',
      );

      expect(result.hexSize.width, greaterThan(0));
      expect(result.hexSize.height, greaterThan(0));
      expect(result.lines, isNotEmpty);
      expect(result.lineWidths, isNotEmpty);
      expect(result.circumradius, greaterThan(0));
    });

    testWidgets('computeOctagon returns valid layout data', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      final context = tester.element(find.byType(Container));

      final result = NodeLayoutCalculator.computeOctagon(
        title: 'Speed Layer 0',
        edgeLength: 140.0,
        level: 0,
        cornerRadiusFactor: 0.1,
        titleStyle: const TextStyle(fontSize: 18),
        context: context,
        baseColor: Colors.blue,
        isFocused: false,
        id: 'test_id',
      );

      expect(result.nodeSize.width, greaterThan(0));
      expect(result.nodeSize.height, greaterThan(0));
      expect(result.lines, isNotEmpty);
      expect(result.lineWidths, isNotEmpty);
      expect(result.circumradius, greaterThan(0));
    });

    testWidgets('Color calculations match expected logic for Hex', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Container()));
      final context = tester.element(find.byType(Container));

      final resultFocused = NodeLayoutCalculator.computeHex(
        title: 'Title',
        edgeLength: 100,
        level: 0,
        cornerRadiusFactor: 0.1,
        titleStyle: const TextStyle(),
        context: context,
        baseColor: Colors.red,
        isFocused: true,
        id: '1',
      );

      final resultUnfocused = NodeLayoutCalculator.computeHex(
        title: 'Title',
        edgeLength: 100,
        level: 0,
        cornerRadiusFactor: 0.1,
        titleStyle: const TextStyle(),
        context: context,
        baseColor: Colors.red,
        isFocused: false,
        id: '1',
      );

      // Focused border should be lighter/different than unfocused
      expect(
        resultFocused.borderColor,
        isNot(equals(resultUnfocused.borderColor)),
      );
    });
  });
}
