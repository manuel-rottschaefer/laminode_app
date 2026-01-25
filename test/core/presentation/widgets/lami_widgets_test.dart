import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/presentation/widgets/lami_input.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dropdown.dart';

void main() {
  group('LamiInput', () {
    testWidgets('should render with label and hint', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LamiInput(
              label: 'Test Label',
              hintText: 'Test Hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('should update value on change', (tester) async {
      String? changedValue;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LamiInput(
              onChanged: (val) => changedValue = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'new value');
      expect(changedValue, 'new value');
    });
  });

  group('LamiDropdown', () {
    testWidgets('should render with label and items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LamiDropdown<int>(
              label: 'Test Dropdown',
              value: 1,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Option 1')),
                DropdownMenuItem(value: 2, child: Text('Option 2')),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Dropdown'), findsOneWidget);
      expect(find.text('Option 1'), findsOneWidget);
    });
  });
}
