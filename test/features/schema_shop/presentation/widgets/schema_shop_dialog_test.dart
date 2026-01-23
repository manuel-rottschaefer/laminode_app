import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/schema_shop_dialog.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';

class MockSchemaShopNotifier extends StateNotifier<SchemaShopState> with Mock implements SchemaShopNotifier {
  MockSchemaShopNotifier(super.state);
}

void main() {
  late MockSchemaShopNotifier mockNotifier;

  setUp(() {
    registerFallbackValue(SchemaShopState());
  });

  testWidgets('should render search bar and loading state', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    mockNotifier = MockSchemaShopNotifier(SchemaShopState(isLoading: true));
    when(() => mockNotifier.fetchPlugins()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [schemaShopProvider.overrideWith((ref) => mockNotifier)],
        child: const MaterialApp(home: Scaffold(body: SchemaShopDialog())),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show plugins when state is loaded', (tester) async {
    final tPlugin = PluginManifest(
      pluginType: 'sector',
      displayName: 'Test Sector',
      description: 'Test Desc',
      plugin: PluginInfo(
        pluginID: 'test_sector',
        pluginVersion: '1.0.0',
        pluginAuthor: 'Author',
        publishedDate: '2023-01-01',
        sector: 'FDM',
      ),
      schemas: const [],
    );

    mockNotifier = MockSchemaShopNotifier(SchemaShopState(availablePlugins: [tPlugin], isLoading: false));
    when(() => mockNotifier.fetchPlugins()).thenAnswer((_) async {});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [schemaShopProvider.overrideWith((ref) => mockNotifier)],
        child: const MaterialApp(home: Scaffold(body: SchemaShopDialog())),
      ),
    );

    expect(find.text('Test Sector'), findsOneWidget);
  });
}
