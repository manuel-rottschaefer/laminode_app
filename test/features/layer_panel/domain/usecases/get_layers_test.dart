import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/get_layers.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late GetLayersUseCase useCase;
  late MockLayerPanelRepository mockRepository;

  setUp(() {
    mockRepository = MockLayerPanelRepository();
    useCase = GetLayersUseCase(mockRepository);
  });

  const tLayerEntries = [
    LamiLayerEntry(
      layerName: 'Test Layer 1',
      layerAuthor: 'Author 1',
      layerDescription: 'Description 1',
      parameters: [],
    ),
    LamiLayerEntry(
      layerName: 'Test Layer 2',
      layerAuthor: 'Author 2',
      layerDescription: 'Description 2',
      parameters: [],
    ),
  ];

  test('should get layers from repository', () {
    // arrange
    when(() => mockRepository.getLayers()).thenReturn(tLayerEntries);
    // act
    final result = useCase();
    // assert
    expect(result, tLayerEntries);
    verify(() => mockRepository.getLayers()).called(1);
  });
}
