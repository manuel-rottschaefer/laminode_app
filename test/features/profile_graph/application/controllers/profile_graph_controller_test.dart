import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/profile_graph/application/controllers/profile_graph_controller.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_snapshot_providers.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/load_graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/save_graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_node_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vector_math/vector_math_64.dart';

class MockRef extends Mock implements Ref {}
class MockParamPanelNotifier extends Mock implements ParamPanelNotifier {}
class MockSaveGraphSnapshot extends Mock implements SaveGraphSnapshot {}
class MockLoadGraphSnapshot extends Mock implements LoadGraphSnapshot {}
class FakeGraphSnapshot extends Fake implements GraphSnapshot {}
class MockProviderSubscription<T> extends Mock implements ProviderSubscription<T> {}
class FakeProviderListenable extends Fake implements ProviderListenable<GraphData> {}

void main() {
  late ProfileGraphController controller;
  late MockRef mockRef;
  late MockParamPanelNotifier mockParamPanelNotifier;
  late MockSaveGraphSnapshot mockSaveUseCase;
  late MockLoadGraphSnapshot mockLoadUseCase;

  setUpAll(() {
    registerFallbackValue(FakeGraphSnapshot());
    registerFallbackValue(FakeProviderListenable());
  });

  setUp(() {
    mockRef = MockRef();
    mockParamPanelNotifier = MockParamPanelNotifier();
    mockSaveUseCase = MockSaveGraphSnapshot();
    mockLoadUseCase = MockLoadGraphSnapshot();
    
    // Stub provider reads
    when(() => mockRef.read(paramPanelProvider.notifier)).thenReturn(mockParamPanelNotifier);
    when(() => mockRef.read(saveGraphSnapshotUseCaseProvider)).thenReturn(mockSaveUseCase);
    when(() => mockRef.read(loadGraphSnapshotUseCaseProvider)).thenReturn(mockLoadUseCase);
    
    // ParamPanelState
    when(() => mockRef.read(paramPanelProvider)).thenReturn(ParamPanelState());

    // Stub listen
    when(() => mockRef.listen<GraphData>(any(), any(), fireImmediately: any(named: 'fireImmediately')))
        .thenReturn(MockProviderSubscription<GraphData>());

    controller = ProfileGraphController(mockRef);
  });

  test('should initialize with visual controller', () {
    expect(controller.visualController, isNotNull);
    expect(controller.visualController.graph, isNotNull);
  });

  group('Snapshots', () {
    test('getSnapshot should return current graph state', () {
      // Add a node to graph manually to verify it's captured
      controller.visualController.addNode('node1', initialPosition: Vector2(10, 10));
      
      final snapshot = controller.getSnapshot();
      
      expect(snapshot, isNotNull);
      expect(snapshot!.nodes.length, 1);
      expect(snapshot.nodes.first.id, 'node1');
      expect(snapshot.nodes.first.position?.x, 10);
    });

    test('saveCurrentSnapshot should call use case', () async {
      controller.visualController.addNode('node1');
      when(() => mockSaveUseCase.execute(any())).thenAnswer((_) async {});
      
      await controller.saveCurrentSnapshot();
      
      verify(() => mockSaveUseCase.execute(any())).called(1);
    });

    test('loadSnapshot should call use case and apply', () async {
      final tSnapshot = GraphSnapshot(nodes: [
        GraphNodeModel(id: 'node1', label: '', shape: GraphNodeShape.none, position: Vector2(5, 5), isBranching: true)
      ]);
      when(() => mockLoadUseCase.execute()).thenAnswer((_) async => tSnapshot);
      when(() => mockParamPanelNotifier.setBranchedParamNames(any())).thenReturn(null);
      
      await controller.loadSnapshot();
      
      verify(() => mockLoadUseCase.execute()).called(1);
      verify(() => mockParamPanelNotifier.setBranchedParamNames({'node1'})).called(1);
      
      // Check if position was applied (pending positions logic)
      // Since applying happens asynchronously or via sync, we might not see it immediately 
      // unless we simulate the graph sync or check pending positions if exposed (they are private).
      // However, applySnapshot calls visualController.graph.edges.clear()
      expect(controller.visualController.graph.edges, isEmpty);
    });
  });

  group('applySnapshot', () {
    test('should set branched param names and clear edges', () {
      final tSnapshot = GraphSnapshot(nodes: [
        GraphNodeModel(id: 'node1', label: '', shape: GraphNodeShape.none, isBranching: true)
      ]);
      
      controller.applySnapshot(tSnapshot);
      
      verify(() => mockParamPanelNotifier.setBranchedParamNames({'node1'})).called(1);
      expect(controller.visualController.graph.edges, isEmpty);
    });
  });
}
