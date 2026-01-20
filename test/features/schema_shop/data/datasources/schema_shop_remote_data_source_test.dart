import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/schema_shop_remote_data_source.dart';
import 'package:laminode_app/features/schema_shop/data/models/plugin_manifest_model.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late SchemaShopRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dataSource = SchemaShopRemoteDataSourceImpl(mockDio);
  });

  group('getAvailablePlugins', () {
    final tPluginJson = [
      {
        'pluginType': 'application',
        'displayName': 'Test Plugin',
        'description': 'Test Description',
        'plugin': {
          'pluginID': 'test_plugin',
          'pluginVersion': '1.0.0',
          'pluginAuthor': 'Author',
          'publishedDate': '2023-01-01',
          'sector': 'FDM',
        },
        'schemas': [
          {'id': 'v1', 'version': '1.0.0', 'releaseDate': '2023-01-01'},
        ],
      },
    ];

    test('should perform a GET request on /plugins/discover', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tPluginJson,
          statusCode: 200,
          requestOptions: RequestOptions(path: 'plugins/discover'),
        ),
      );
      // act
      await dataSource.getAvailablePlugins();
      // assert
      verify(() => mockDio.get('plugins/discover')).called(1);
    });

    test(
      'should return list of PluginManifestModel when the response code is 200',
      () async {
        // arrange
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: tPluginJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: 'plugins/discover'),
          ),
        );
        // act
        final result = await dataSource.getAvailablePlugins();
        // assert
        expect(result, isA<List<PluginManifestModel>>());
        expect(result.first.displayName, 'Test Plugin');
      },
    );

    test('should throw a DioException when the response code is 404', () async {
      // arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: 'Something went wrong',
          statusCode: 404,
          requestOptions: RequestOptions(path: 'plugins/discover'),
        ),
      );
      // act
      final call = dataSource.getAvailablePlugins;
      // assert
      expect(() => call(), throwsA(isA<DioException>()));
    });
  });

  group('downloadAdapter', () {
    test('should perform a GET request on plugins/test_id/adapter', () async {
      // arrange
      const tPluginId = 'test_id';
      when(() => mockDio.get(any(), options: any(named: 'options'))).thenAnswer(
        (_) async => Response(
          data: [1, 2, 3],
          statusCode: 200,
          requestOptions: RequestOptions(path: 'plugins/$tPluginId/adapter'),
        ),
      );
      // act
      await dataSource.downloadAdapter(tPluginId);
      // assert
      verify(
        () => mockDio.get(
          'plugins/$tPluginId/adapter',
          options: any(named: 'options'),
        ),
      ).called(1);
    });
  });

  group('downloadSchema', () {
    test(
      'should perform a GET request on plugins/test_id/schemas/v1',
      () async {
        // arrange
        const tPluginId = 'test_id';
        const tSchemaId = 'v1';
        when(() => mockDio.get(any())).thenAnswer(
          (_) async => Response(
            data: {'id': 'v1'},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: 'plugins/$tPluginId/schemas/$tSchemaId',
            ),
          ),
        );
        // act
        await dataSource.downloadSchema(tPluginId, tSchemaId);
        // assert
        verify(
          () => mockDio.get('plugins/$tPluginId/schemas/$tSchemaId'),
        ).called(1);
      },
    );
  });
}
