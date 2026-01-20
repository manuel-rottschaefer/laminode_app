import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/update_layer_name.dart';

import '../../../../mocks/mocks.dart';

class FakeLayerEntry extends Fake implements LamiLayerEntry {}

void main() {
  late UpdateLayerNameUseCase useCase;
  late MockLayerPanelRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeLayerEntry());
  });

  setUp(() {
    mockRepository = MockLayerPanelRepository();
    useCase = UpdateLayerNameUseCase(mockRepository);
  });

  const tLayer = LamiLayerEntry(
    layerName: 'Old Name',
    layerAuthor: 'Author',
    layerDescription: 'Desc',
    parameters: [],
  );

  test('should update layer name when index is valid', () {
    // arrange
    when(() => mockRepository.getLayers()).thenReturn([tLayer]);
    when(() => mockRepository.updateLayer(any(), any())).thenReturn(null);

    // act
    useCase(0, 'New Name');

    // assert
    verify(() => mockRepository.getLayers()).called(1);
    final captured =
        verify(
              () => mockRepository.updateLayer(0, captureAny()),
            ).captured.single
            as LamiLayerEntry;
    expect(captured.layerName, 'New Name');
  });

  test('should not update layer name when index is invalid', () {
    // arrange
    when(() => mockRepository.getLayers()).thenReturn([tLayer]);

    // act
    useCase(1, 'New Name');

    // assert
    verify(() => mockRepository.getLayers()).called(1);
    verifyNever(() => mockRepository.updateLayer(any(), any()));
  });
}
