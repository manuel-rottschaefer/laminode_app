import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/schema_editor_footer.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';

void main() {
  testWidgets('SchemaEditorFooter should render buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(bottomNavigationBar: SchemaEditorFooter()),
        ),
      ),
    );

    expect(find.byType(LamiButton), findsAtLeastNWidgets(2));
    expect(find.text('Save Schema'), findsOneWidget);
    expect(find.text('Export Bundle'), findsOneWidget);
  });
}
