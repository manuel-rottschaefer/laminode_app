import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_management/data/repositories/layer_management_repository_impl.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../mocks/mocks.dart';

void main() {
  late LayerManagementRepositoryImpl repository;
  late MockLayerLocalDataSource mockDataSource;
  late Directory tempDir;

  const tLayer = LamiLayerEntry(
    layerName: 'Test Layer',
    layerAuthor: 'Author',
    layerDescription: 'Description',
    parameters: [],
  );

  setUpAll(() {
    registerFallbackValue(tLayer);
  });

  setUp(() {
    mockDataSource = MockLayerLocalDataSource();
    repository = LayerManagementRepositoryImpl(mockDataSource);
    tempDir = Directory.systemTemp.createTempSync();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('LayerManagementRepository', () {
    test('should call saveLayer on datasource', () async {
      when(() => mockDataSource.saveLayer(any())).thenAnswer((_) async {});
      await repository.saveLayerToStorage(tLayer);
      verify(() => mockDataSource.saveLayer(tLayer)).called(1);
    });

    test('should call getInstalledLayers on datasource', () async {
      when(
        () => mockDataSource.getInstalledLayers(),
      ).thenAnswer((_) async => [tLayer]);
      final result = await repository.getStoredLayers();
      expect(result, [tLayer]);
      verify(() => mockDataSource.getInstalledLayers()).called(1);
    });

    test('should export layer to file', () async {
      final filePath = '${tempDir.path}/test_layer.json';
      await repository.exportLayer(tLayer, filePath);

      final file = File(filePath);
      expect(await file.exists(), true);
      final content = await file.readAsString();
      final jsonMap = jsonDecode(content);
      expect(jsonMap['layerName'], tLayer.layerName);
    });

    test('should import layer from file', () async {
      when(() => mockDataSource.saveLayer(any())).thenAnswer((_) async {});
      final filePath = '${tempDir.path}/test_layer.json';
      final jsonMap = {
        'layerName': 'Imported Layer',
        'layerAuthor': 'Admin',
        'layerDescription': 'Desc',
        'isActive': true,
        'isLocked': false,
        'parameters': [],
      };
      await File(filePath).writeAsString(jsonEncode(jsonMap));

      final result = await repository.importLayer(filePath);

      expect(result, isNotNull);
      expect(result!.layerName, 'Imported Layer');
      verify(() => mockDataSource.saveLayer(any())).called(1);
    });
  });
}
