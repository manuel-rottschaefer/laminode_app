import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/plugin_local_data_source_mixin.dart';
import 'package:laminode_app/features/schema_shop/data/datasources/manual_schema_local_data_source_mixin.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProvider extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getApplicationSupportPath() async => '/tmp';

  @override
  Future<String?> getTemporaryPath() async => '/tmp';
  @override
  Future<String?> getApplicationDocumentsPath() async => '/tmp';
  @override
  Future<String?> getLibraryPath() async => '/tmp';
  @override
  Future<String?> getExternalStoragePath() async => '/tmp';
  @override
  Future<List<String>?> getExternalCachePaths() async => ['/tmp'];
  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => ['/tmp'];
  @override
  Future<String?> getDownloadsPath() async => '/tmp';
}

class TestLocalDataSource
    with PluginLocalDataSourceMixin, ManualSchemaLocalDataSourceMixin {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PathProviderPlatform.instance = MockPathProvider();
  });

  group('LocalDataSourceMixins', () {
    final dataSource = TestLocalDataSource();

    test('pluginsPath should return correct path', () async {
      final path = await dataSource.pluginsPath;
      expect(path, contains('plugins'));
    });
  });
}
