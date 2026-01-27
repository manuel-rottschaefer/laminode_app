import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/schema_editor_body.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/adapter_editor_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_list_widget.dart';

void main() {
  testWidgets('SchemaEditorBody should render schema view by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SchemaEditorBody(viewMode: SchemaEditorViewMode.schema),
          ),
        ),
      ),
    );

    expect(find.byType(AdapterEditorWidget), findsOneWidget);
  });

  testWidgets('SchemaEditorBody should render parameters view', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SchemaEditorBody(viewMode: SchemaEditorViewMode.parameters),
          ),
        ),
      ),
    );

    expect(find.byType(ParamListWidget), findsOneWidget);
  });
}
