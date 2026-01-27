import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/categories_editor_widget.dart';

void main() {
  testWidgets('CategoriesEditorWidget should render categories header', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: Scaffold(body: CategoriesEditorWidget())),
      ),
    );

    expect(find.text('CATEGORIES'), findsOneWidget);
  });
}
