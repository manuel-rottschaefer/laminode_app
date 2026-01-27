import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_edge.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_node_model.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('GraphEdge', () {
    test('should have correct id based on source and target', () {
      const edge = GraphEdge('source', 'target');
      expect(edge.id, 'source|target');
    });

    test('should be equal if source and target are same', () {
      const edge1 = GraphEdge('a', 'b');
      const edge2 = GraphEdge('a', 'b');
      expect(edge1, edge2);
      expect(edge1.hashCode, edge2.hashCode);
    });
  });

  group('GraphData', () {
    test('should allow empty creation', () {
      const data = GraphData.empty();
      expect(data.nodes, isEmpty);
      expect(data.edges, isEmpty);
      expect(data.isEmpty, true);
    });

    test('should store nodes and edges', () {
      final node = GraphNodeModel(id: '1', label: '1', shape: GraphNodeShape.none);
      const edge = GraphEdge('1', '2');
      final data = GraphData(
        nodes: {'1': node},
        edges: {edge},
      );
      expect(data.nodes.length, 1);
      expect(data.edges.length, 1);
      expect(data.isEmpty, false);
    });
  });

  group('GraphSnapshot', () {
    test('should store nodes, positions and branched params', () {
      final node = GraphNodeModel(id: '1', label: '1', shape: GraphNodeShape.none);
      final pos = Vector2(10, 10);
      final snapshot = GraphSnapshot(
        nodes: [node],
        nodePositions: {'1': pos},
        branchedParamNames: ['p1'],
      );

      expect(snapshot.nodes.first, node);
      expect(snapshot.nodePositions['1'], pos);
      expect(snapshot.branchedParamNames.first, 'p1');
    });

    test('copyWith should update fields', () {
      final snapshot = const GraphSnapshot();
      final node = GraphNodeModel(id: '1', label: '1', shape: GraphNodeShape.none);
      
      final updated = snapshot.copyWith(nodes: [node]);
      expect(updated.nodes.length, 1);
      
      final updated2 = updated.copyWith(branchedParamNames: ['p1']);
      expect(updated2.branchedParamNames, ['p1']);
      expect(updated2.nodes.length, 1); // Should retain
    });
  });
}
