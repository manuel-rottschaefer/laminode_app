import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_panel/data/datasources/layer_local_data_source.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String _appSupportPath;

  MockPathProviderPlatform(this._appSupportPath);

  @override
  Future<String?> getApplicationSupportPath() async {
    return _appSupportPath;
  }
}

void main() {
  group('LayerLocalDataSource', () {
    late LayerLocalDataSourceImpl dataSource;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('test_layers');
      PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
      dataSource = LayerLocalDataSourceImpl();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('saveLayer and getInstalledLayers', () async {
      final layer = const LamiLayerEntry(
        layerName: 'Test Layer',
        parameters: [],
        layerAuthor: 'author',
        layerDescription: 'A test layer',
        layerCategory: 'Test',
      );

      await dataSource.saveLayer(layer);

      final layers = await dataSource.getInstalledLayers();

      expect(layers.length, 1);
      expect(layers.first.layerName, 'Test Layer');
      expect(layers.first.layerDescription, 'A test layer');
    });
  });
}
