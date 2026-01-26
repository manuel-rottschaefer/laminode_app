import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_local_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_remote_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/data/repositories/schema_shop_repository_impl.dart';

class MockRemoteDataSource extends Mock implements SchemaShopRemoteDataSource {}

class MockLocalDataSource extends Mock implements SchemaShopLocalDataSource {}

class PluginManifestModelFake extends Fake implements PluginManifestModel {}

void main() {
  late SchemaShopRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(PluginManifestModelFake());
  });

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repository = SchemaShopRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
    );
    when(() => mockLocalDataSource.pluginsPath).thenAnswer((_) async => '/tmp');
  });

  final tPluginManifestModel = PluginManifestModel(
    pluginType: 'application',
    displayName: 'Test',
    description: 'Desc',
    plugin: PluginInfoModel(
      pluginID: 'test_id',
      pluginVersion: '1.0.0',
      pluginAuthor: 'Author',
      publishedDate: '2023-01-01',
      sector: 'FDM',
    ),
    schemas: [
      SchemaRefModel(id: 'v1', version: '1.0.0', releaseDate: '2023-01-01'),
    ],
  );

  group('getAvailablePlugins', () {
    test(
      'should return remote data when the call to remote data source is successful',
      () async {
        // arrange
        when(
          () => mockRemoteDataSource.getAvailablePlugins(),
        ).thenAnswer((_) async => [tPluginManifestModel]);
        // act
        final result = await repository.getAvailablePlugins();
        // assert
        verify(() => mockRemoteDataSource.getAvailablePlugins());
        expect(result, [tPluginManifestModel]);
      },
    );
  });

  group('installPlugin', () {
    test(
      'should download adapter and schema and save to local data source',
      () async {
        // arrange
        const tSchemaId = 'v1';
        final tSchemaJson = {'id': 'v1'};
        final tAdapterBytes = [1, 2, 3];

        when(
          () => mockRemoteDataSource.downloadAdapter(any()),
        ).thenAnswer((_) async => tAdapterBytes);
        when(
          () => mockRemoteDataSource.downloadSchema(any(), any()),
        ).thenAnswer((_) async => tSchemaJson);
        when(
          () => mockLocalDataSource.savePlugin(any(), any(), any(), any()),
        ).thenAnswer((_) async => {});

        // act
        await repository.installPlugin(tPluginManifestModel, tSchemaId);

        // assert
        verify(
          () => mockRemoteDataSource.downloadAdapter(
            tPluginManifestModel.plugin.pluginID,
          ),
        );
        verify(
          () => mockRemoteDataSource.downloadSchema(
            tPluginManifestModel.plugin.pluginID,
            tSchemaId,
          ),
        );
        verify(
          () => mockLocalDataSource.savePlugin(
            tPluginManifestModel,
            tAdapterBytes,
            tSchemaId,
            tSchemaJson,
          ),
        );
      },
    );
  });

  group('uninstallPlugin', () {
    test('should call removePlugin on local data source', () async {
      // arrange
      const tPluginId = 'test_id';
      when(
        () => mockLocalDataSource.removePlugin(any()),
      ).thenAnswer((_) async => {});
      // act
      await repository.uninstallPlugin(tPluginId);
      // assert
      verify(() => mockLocalDataSource.removePlugin(tPluginId));
    });
  });

  group('schemaExists', () {
    test(
      'should return true when local data source returns a schema',
      () async {
        when(
          () => mockLocalDataSource.schemaExists(any(), any(), any()),
        ).thenAnswer((_) async => true);

        final result = await repository.schemaExists('App', '1.0', 'v1');

        expect(result, true);
        verify(() => mockLocalDataSource.schemaExists('App', '1.0', 'v1'));
      },
    );

    test('should return false when local data source returns null', () async {
      when(
        () => mockLocalDataSource.schemaExists(any(), any(), any()),
      ).thenAnswer((_) async => false);

      final result = await repository.schemaExists('App', '1.0', 'v1');

      expect(result, false);
    });
  });

  group('applicationExists', () {
    test('should call local data source applicationExists', () async {
      when(
        () => mockLocalDataSource.applicationExists(any()),
      ).thenAnswer((_) async => true);

      final result = await repository.applicationExists('App');

      expect(result, true);
      verify(() => mockLocalDataSource.applicationExists('App'));
    });
  });
}
