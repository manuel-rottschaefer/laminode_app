import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/layer_panel/domain/usecases/remove_layer.dart';

import '../../../../mocks/mocks.dart';

void main() {
  late RemoveLayerUseCase useCase;
  late MockLayerPanelRepository mockRepository;

  setUp(() {
    mockRepository = MockLayerPanelRepository();
    useCase = RemoveLayerUseCase(mockRepository);
  });

  test('should call removeLayer on repository', () {
    // arrange
    when(() => mockRepository.removeLayer(any())).thenReturn(null);

    // act
    useCase(0);

    // assert
    verify(() => mockRepository.removeLayer(0)).called(1);
  });
}
