import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/domain/repositories/schema_shop_repository.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/profile_manager/domain/repositories/profile_repository.dart';

class MockSchemaShopRepository extends Mock implements SchemaShopRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockSchemaShopRepository mockRepository;
  late MockProfileRepository mockProfileRepository;
  late ProviderContainer container;

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
    schemas: [
      SchemaRef(id: 'schema_1', version: '1.0.0', releaseDate: '2023-01-01'),
      SchemaRef(id: 'schema_2', version: '1.1.0', releaseDate: '2023-02-01'),
    ],
  );

  setUp(() async {
    mockRepository = MockSchemaShopRepository();
    mockProfileRepository = MockProfileRepository();
    
    // Default stubs
    when(() => mockRepository.getAvailablePlugins())
        .thenAnswer((_) async => [tPlugin]);
    when(() => mockRepository.getInstalledPlugins())
        .thenAnswer((_) async => [tPlugin]);
    when(() => mockRepository.getInstalledSchemaIds())
        .thenAnswer((_) async => ['schema_1']);

    container = ProviderContainer(
      overrides: [
        schemaShopRepositoryProvider.overrideWithValue(mockRepository),
        profileRepositoryProvider.overrideWithValue(mockProfileRepository),
      ],
    );

    // Initial load
    await container.read(schemaShopProvider.notifier).fetchPlugins();
    await container.read(schemaShopProvider.notifier).refreshInstalled();
  });

  tearDown(() {
    container.dispose();
  });

  group('SchemaShopNotifier', () {
    test('state should be loaded after init', () async {
      expect(container.read(schemaShopProvider).availablePlugins, [tPlugin]);
      expect(container.read(schemaShopProvider).isLoading, false);
    });

    test('fetchPlugins updates state on error', () async {
      when(() => mockRepository.getAvailablePlugins())
          .thenThrow(Exception('fetch error'));
      
      await container.read(schemaShopProvider.notifier).fetchPlugins();
      
      expect(container.read(schemaShopProvider).error, contains('fetch error'));
    });
  });

  group('SchemaShop derived providers', () {
    test('installedApplicationsProvider should filter correctly', () {
      final installed = container.read(installedApplicationsProvider);
      expect(installed.length, 1);
      expect(installed.first.plugin.pluginID, 'test_plugin');
    });

    test('installedSchemasForAppProvider should filter by installed schema IDs', () {
      final schemas = container.read(installedSchemasForAppProvider('test_plugin'));
      expect(schemas.length, 1);
      expect(schemas.first.id, 'schema_1');
    });

    test('schemaByIdProvider should find the correct schema', () {
      final schema = container.read(schemaByIdProvider('schema_2'));
      expect(schema?.id, 'schema_2');
    });

    test('filteredAndGroupedPluginsProvider should filter by search query', () {
      final results = container.read(filteredAndGroupedPluginsProvider('Nonexistent'));
      expect(results, isEmpty);
      
      final found = container.read(filteredAndGroupedPluginsProvider('Test'));
      expect(found, isNotEmpty);
      expect(found.first, isA<ApplicationGroup>());
    });
  });
}
