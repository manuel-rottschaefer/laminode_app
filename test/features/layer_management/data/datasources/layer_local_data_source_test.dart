import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_management/data/datasources/layer_local_data_source.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock PathProviderPlatform to control where files are saved in tests
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
  late LayerLocalDataSourceImpl dataSource;
  late Directory tempDir;

  setUp(() async {
    // Create a temporary directory for each test
    tempDir = await Directory.systemTemp.createTemp(
      'layer_local_data_source_test',
    );
    // Set up the mock path provider
    PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
    dataSource = LayerLocalDataSourceImpl();
  });

  tearDown(() {
    // Clean up the temporary directory after each test
    tempDir.deleteSync(recursive: true);
  });

  group('LayerLocalDataSource', () {
    const tLayerEntry = LamiLayerEntry(
      layerName: 'TestLayer',
      parameters: [],
      layerAuthor: 'test_author',
      layerDescription: 'test_description',
    );

    test('saveLayer creates directory and saves a layer file', () async {
      // Act
      await dataSource.saveLayer(tLayerEntry);

      // Assert
      final layersDir = Directory(p.join(tempDir.path, 'layers'));
      expect(await layersDir.exists(), isTrue);

      final layerFile = File(
        p.join(layersDir.path, '${tLayerEntry.layerName}.lmdl'),
      );
      expect(await layerFile.exists(), isTrue);

      final fileContent = await layerFile.readAsString();
      expect(fileContent, contains('"layerName":"TestLayer"'));
    });

    test('getInstalledLayers returns a list of layers', () async {
      // Arrange
      await dataSource.saveLayer(tLayerEntry);

      // Act
      final result = await dataSource.getInstalledLayers();

      // Assert
      expect(result, isA<List<LamiLayerEntry>>());
      expect(result.length, 1);
      expect(result.first.layerName, tLayerEntry.layerName);
    });

    test(
      'getInstalledLayers returns an empty list if directory does not exist',
      () async {
        // This test needs to run with a fresh data source instance where the directory hasn't been created.
        final freshDataSource = LayerLocalDataSourceImpl();
        final freshTempDir = await Directory.systemTemp.createTemp(
          'fresh_test',
        );
        PathProviderPlatform.instance = MockPathProviderPlatform(
          freshTempDir.path,
        );

        addTearDown(() => freshTempDir.deleteSync(recursive: true));

        // Act
        final result = await freshDataSource.getInstalledLayers();

        // Assert
        expect(result, isA<List<LamiLayerEntry>>());
        expect(result.isEmpty, isTrue);
      },
    );

    test('getInstalledLayers handles corrupted files gracefully', () async {
      // Arrange
      final layersDir = Directory(p.join(tempDir.path, 'layers'));
      await layersDir.create(recursive: true);

      final corruptedFile = File(p.join(layersDir.path, 'corrupted.lmdl'));
      await corruptedFile.writeAsString('this is not a valid json');

      await dataSource.saveLayer(tLayerEntry);

      // Act
      final result = await dataSource.getInstalledLayers();

      // Assert
      expect(result, isA<List<LamiLayerEntry>>());
      expect(result.length, 1);
      expect(result.first.layerName, tLayerEntry.layerName);
    });
  });
}
