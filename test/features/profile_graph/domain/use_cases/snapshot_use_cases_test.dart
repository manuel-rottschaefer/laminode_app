import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/repositories/graph_snapshot_repository.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/save_graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/load_graph_snapshot.dart';
import 'package:vector_math/vector_math_64.dart';

class MockGraphSnapshotRepository extends Mock
    implements GraphSnapshotRepository {}

// Register fallback values for mocktail
class FakeGraphSnapshot extends Fake implements GraphSnapshot {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeGraphSnapshot());
  });

  late MockGraphSnapshotRepository mockRepository;
  late SaveGraphSnapshot saveUseCase;
  late LoadGraphSnapshot loadUseCase;

  setUp(() {
    mockRepository = MockGraphSnapshotRepository();
    saveUseCase = SaveGraphSnapshot(mockRepository);
    loadUseCase = LoadGraphSnapshot(mockRepository);
  });

  final testSnapshot = GraphSnapshot(
    nodePositions: {'node1': Vector2(100, 200), 'node2': Vector2(300, 400)},
    branchedParamNames: {'param1', 'param2'},
  );

  group('Graph Snapshot Use Cases', () {
    test('SaveGraphSnapshot should call repository.saveSnapshot', () async {
      // arrange
      when(
        () => mockRepository.saveSnapshot(any()),
      ).thenAnswer((_) async => Future.value());

      // act
      await saveUseCase.execute(testSnapshot);

      // assert
      verify(() => mockRepository.saveSnapshot(testSnapshot)).called(1);
    });

    test('LoadGraphSnapshot should return snapshot from repository', () async {
      // arrange
      when(
        () => mockRepository.loadSnapshot(),
      ).thenAnswer((_) async => testSnapshot);

      // act
      final result = await loadUseCase.execute();

      // assert
      expect(result, testSnapshot);
      verify(() => mockRepository.loadSnapshot()).called(1);
    });

    test(
      'LoadGraphSnapshot should return null when repository returns null',
      () async {
        // arrange
        when(() => mockRepository.loadSnapshot()).thenAnswer((_) async => null);

        // act
        final result = await loadUseCase.execute();

        // assert
        expect(result, isNull);
        verify(() => mockRepository.loadSnapshot()).called(1);
      },
    );
  });

  group('GraphSnapshot Entity', () {
    test('toJson and fromJson should be symmetrical', () {
      // act
      final json = testSnapshot.toJson();
      final result = GraphSnapshot.fromJson(json);

      // assert
      expect(
        result.nodePositions['node1']?.x,
        testSnapshot.nodePositions['node1']?.x,
      );
      expect(
        result.nodePositions['node1']?.y,
        testSnapshot.nodePositions['node1']?.y,
      );
      expect(
        result.nodePositions['node2']?.x,
        testSnapshot.nodePositions['node2']?.x,
      );
      expect(
        result.nodePositions['node2']?.y,
        testSnapshot.nodePositions['node2']?.y,
      );
      expect(result.branchedParamNames, testSnapshot.branchedParamNames);
    });
  });
}
