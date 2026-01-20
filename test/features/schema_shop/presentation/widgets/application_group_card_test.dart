import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/application_group_card.dart';

class MockSchemaShopNotifier extends StateNotifier<SchemaShopState>
    with Mock
    implements SchemaShopNotifier {
  MockSchemaShopNotifier() : super(SchemaShopState());
}

void main() {
  late MockSchemaShopNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockSchemaShopNotifier();
  });

  final tPlugin = PluginManifest(
    pluginType: 'application',
    displayName: 'Test Plugin',
    description: 'Test Description',
    application: ApplicationInfo(
      appName: 'Test App',
      appVersion: '1.0.0',
      vendor: 'Test Vendor',
      website: '',
      sector: 'FDM',
    ),
    plugin: PluginInfo(
      pluginID: 'test_plugin',
      pluginVersion: '1.0.0',
      pluginAuthor: 'Author',
      publishedDate: '2023-01-01',
      sector: 'FDM',
    ),
    schemas: [],
  );

  final tGroup = ApplicationGroup(
    appName: 'Test App',
    vendor: 'Test Vendor',
    sector: 'FDM',
    appVersions: [tPlugin],
  );

  testWidgets('should render group information and expand on tap', (
    tester,
  ) async {
    // arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [schemaShopProvider.overrideWith((ref) => mockNotifier)],
        child: MaterialApp(
          home: Scaffold(
            body: ApplicationGroupCard(
              group: tGroup,
              onInstall: (p, s) {},
              onRemove: (id) {},
            ),
          ),
        ),
      ),
    );

    // assert initially
    expect(find.text('Test App'), findsOneWidget);
    expect(find.text('Vendor: Test Vendor'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);

    // act
    await tester.tap(find.text('Test App'));
    await tester.pumpAndSettle();

    // assert expanded
    expect(find.byType(ListView), findsOneWidget);
  });
}
