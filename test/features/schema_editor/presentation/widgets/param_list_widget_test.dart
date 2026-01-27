import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_list_widget.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';

void main() {
  testWidgets('ParamListWidget should render search and empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: Scaffold(body: ParamListWidget())),
      ),
    );

    expect(find.byType(LamiSearch), findsOneWidget);
    expect(find.text('No parameters found'), findsOneWidget);
  });
}
