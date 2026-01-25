import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/schema_editor/presentation/schema_editor_dialog.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';
import 'package:mocktail/mocktail.dart';

class MockSchemaEditorNotifier extends Notifier<SchemaEditorState>
    with Mock
    implements SchemaEditorNotifier {}

void main() {
  setUp(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(1200, 700);
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.resetPhysicalSize();
    binding.platformDispatcher.views.first.resetDevicePixelRatio();
  });

  Widget createWidgetUnderTest() {
    return const ProviderScope(
      child: MaterialApp(home: Scaffold(body: SchemaEditorDialog())),
    );
  }

  testWidgets('should show initial widgets in schema view mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Discard & Close'), findsOneWidget);
    expect(find.text('Export Bundle'), findsOneWidget);
    expect(find.text('Save Schema'), findsOneWidget);
    expect(find.text('Save & Use Schema'), findsOneWidget);
  });

  testWidgets('should show validation error when app not installed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          schemaEditorProvider.overrideWith(
            () => FakeSchemaEditorNotifier(appExists: false, isChecking: false),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: SchemaEditorDialog())),
      ),
    );

    expect(find.text('Application not installed'), findsOneWidget);
  });

  testWidgets('should show version exists warning', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          schemaEditorProvider.overrideWith(
            () => FakeSchemaEditorNotifier(
              appExists: true,
              versionExists: true,
              isChecking: false,
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: SchemaEditorDialog())),
      ),
    );

    expect(find.text('Version already exists'), findsOneWidget);
  });
}

class FakeSchemaEditorNotifier extends SchemaEditorNotifier {
  final bool appExists;
  final bool versionExists;
  final bool isChecking;

  FakeSchemaEditorNotifier({
    this.appExists = false,
    this.versionExists = false,
    this.isChecking = false,
  });

  @override
  SchemaEditorState build() {
    return SchemaEditorState(
      schema: CamSchemaEntry(
        schemaName: 'Test',
        categories: [],
        availableParameters: [],
      ),
      manifest: SchemaManifest(
        schemaType: 'application',
        schemaVersion: '1',
        schemaAuthors: [],
        lastUpdated: '',
      ),
      appExists: appExists,
      versionExists: versionExists,
      isChecking: isChecking,
    );
  }

  @override
  void setViewMode(SchemaEditorViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }
}
