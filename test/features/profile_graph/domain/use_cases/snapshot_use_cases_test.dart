import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/repositories/graph_snapshot_repository.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/save_graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/load_graph_snapshot.dart';
import 'package:vector_math/vector_math_64.dart';

import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_node_model.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_snapshot_model.dart';

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
    nodes: [
      GraphNodeModel(
        id: 'node1',
        label: 'Node 1',
        shape: GraphNodeShape.hex,
        position: Vector2(100, 200),
        isBranching: true,
      ),
      GraphNodeModel(
        id: 'node2',
        label: 'Node 2',
        shape: GraphNodeShape.hex,
        position: Vector2(300, 400),
        isBranching: false,
      ),
    ],
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

  group('GraphSnapshot Model Serialization', () {
    test('toJson and fromJson should be symmetrical', () {
      // arrange
      final model = GraphSnapshotModel.fromEntity(testSnapshot);

      // act
      final json = model.toJson();
      final result = GraphSnapshotModel.fromJson(json);

      // assert
      expect(result.nodes.length, testSnapshot.nodes.length);
      expect(result.nodes[0].id, testSnapshot.nodes[0].id);
      expect(result.nodes[0].position?.x, testSnapshot.nodes[0].position?.x);
      expect(result.nodes[0].isBranching, testSnapshot.nodes[0].isBranching);
      expect(result.nodes[1].id, testSnapshot.nodes[1].id);
      expect(result.nodes[1].position?.x, testSnapshot.nodes[1].position?.x);
      expect(result.nodes[1].isBranching, testSnapshot.nodes[1].isBranching);
    });
  });
}
