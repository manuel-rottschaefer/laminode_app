import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_panel/data/repositories/layer_panel_repository_impl.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late LayerPanelRepositoryImpl repository;
  late Directory tempDir;

  setUp(() {
    repository = LayerPanelRepositoryImpl();
    tempDir = Directory.systemTemp.createTempSync();

    registerFallbackValue(
      const LamiLayerEntry(
        layerName: '',
        layerAuthor: '',
        layerDescription: '',
        parameters: [],
      ),
    );
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  const tLayer = LamiLayerEntry(
    layerName: 'Test Layer',
    layerAuthor: 'Admin',
    layerDescription: 'Desc',
    parameters: [],
  );

  group('Layer management', () {
    test('should add and get layers', () {
      repository.addLayer(tLayer);
      final layers = repository.getLayers();
      expect(layers.length, 1);
      expect(layers.first, tLayer);
    });

    test('should remove layers', () {
      repository.addLayer(tLayer);
      repository.removeLayer(0);
      expect(repository.getLayers().isEmpty, true);
    });

    test('should update layers', () {
      repository.addLayer(tLayer);
      const updatedLayer = LamiLayerEntry(
        layerName: 'Updated',
        layerAuthor: 'Admin',
        layerDescription: 'Desc',
        parameters: [],
      );
      repository.updateLayer(0, updatedLayer);
      expect(repository.getLayers().first.layerName, 'Updated');
    });
  });
}
