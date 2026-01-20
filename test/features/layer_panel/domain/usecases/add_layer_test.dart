import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/add_layer.dart';

import '../../../../mocks/mocks.dart';

class FakeLayerEntry extends Fake implements LamiLayerEntry {}

void main() {
  late AddLayerUseCase useCase;
  late MockLayerPanelRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeLayerEntry());
  });

  setUp(() {
    mockRepository = MockLayerPanelRepository();
    useCase = AddLayerUseCase(mockRepository);
  });

  test('should call addLayer on repository with correct data', () {
    // arrange
    when(() => mockRepository.addLayer(any())).thenReturn(null);

    // act
    useCase(
      name: 'New Layer',
      description: 'New Description',
      category: 'Example Category',
    );

    // assert
    final captured =
        verify(() => mockRepository.addLayer(captureAny())).captured.single
            as LamiLayerEntry;
    expect(captured.layerName, 'New Layer');
    expect(captured.layerDescription, 'New Description');
    expect(captured.layerCategory, 'Example Category');
  });
}
