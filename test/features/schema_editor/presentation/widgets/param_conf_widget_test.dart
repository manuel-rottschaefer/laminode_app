import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_conf_widget.dart';

void main() {
  testWidgets(
    'ParamConfWidget should show empty state when no parameter is selected',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: ParamConfWidget())),
        ),
      );

      expect(find.text('Select a parameter to edit'), findsOneWidget);
    },
  );
}
