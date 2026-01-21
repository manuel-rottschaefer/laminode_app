import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_management/presentation/providers/layer_management_provider.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  group('LayerManagementNotifier', () {
    late LayerManagementNotifier notifier;
    late MockLayerManagementRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockLayerManagementRepository();
      container = ProviderContainer(
        overrides: [
          layerManagementRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      notifier = container.read(layerManagementProvider.notifier);
    });

    test('initial state is correct', () {
      expect(notifier.state.searchQuery, '');
      expect(notifier.state.isImporting, false);
    });

    test('setSearchQuery updates state', () {
      notifier.setSearchQuery('test');
      expect(notifier.state.searchQuery, 'test');
    });

    test('importLayer success', () async {
      const filePath = 'path/to/layer';
      when(
        () => mockRepository.importLayer(filePath),
      ).thenAnswer((_) async => Future.value());
      when(() => mockRepository.getStoredLayers()).thenAnswer(
        (_) async => [
          const LamiLayerEntry(
            layerName: 'test',
            parameters: [],
            layerAuthor: 'author',
            layerDescription: 'description',
          ),
        ],
      );

      final result = await notifier.importLayer(filePath);

      expect(result, isTrue);
      expect(notifier.state.isImporting, false);
      verify(() => mockRepository.importLayer(filePath)).called(1);
    });

    test('importLayer failure', () async {
      const filePath = 'path/to/layer';
      final exception = Exception('Failed to import');
      when(() => mockRepository.importLayer(filePath)).thenThrow(exception);

      final result = await notifier.importLayer(filePath);

      expect(result, isFalse);
      expect(notifier.state.isImporting, false);
      verify(() => mockRepository.importLayer(filePath)).called(1);
    });
  });
}
