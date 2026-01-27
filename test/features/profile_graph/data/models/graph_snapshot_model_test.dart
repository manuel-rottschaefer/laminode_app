import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_node_model.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_snapshot_model.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('GraphSnapshotModel', () {
    final tNodeModel = GraphNodeModel(
      id: 'node_1',
      label: 'test',
      shape: GraphNodeShape.none,
      position: Vector2(0, 0),
    );
    final tSnapshotModel = GraphSnapshotModel(nodes: [tNodeModel]);

    test('should be a subclass of GraphSnapshot', () {
      expect(tSnapshotModel, isA<GraphSnapshot>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON contains nodes', () {
        final Map<String, dynamic> jsonMap = {
          'nodes': [
            {
              'id': 'node_1',
              'position': [0.0, 0.0],
              'isBranching': false,
            }
          ]
        };

        final result = GraphSnapshotModel.fromJson(jsonMap);

        expect(result.nodes.length, 1);
        expect(result.nodes.first.id, 'node_1');
      });

      test('should return empty nodes list when nodes is null or missing', () {
        final Map<String, dynamic> jsonMap = {};
        final result = GraphSnapshotModel.fromJson(jsonMap);
        expect(result.nodes, isEmpty);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        final result = tSnapshotModel.toJson();
        expect(result['nodes'], isA<List>());
        expect((result['nodes'] as List).length, 1);
        expect((result['nodes'] as List).first['id'], 'node_1');
      });
    });

    group('fromEntity', () {
      test('should return a valid model from entity', () {
        final tEntity = GraphSnapshot(nodes: [
            GraphNodeModel(id: '1', label: '', shape: GraphNodeShape.none)
        ]);
        final result = GraphSnapshotModel.fromEntity(tEntity);
        expect(result.nodes.length, 1);
        expect(result.nodes.first, isA<GraphNodeModel>());
      });
    });
    
    group('fromJsonNullable', () {
      test('should return null if input is null', () {
        expect(GraphSnapshotModel.fromJsonNullable(null), isNull);
      });
      
       test('should return valid model if input is valid', () {
        final Map<String, dynamic> jsonMap = {'nodes': []};
        expect(GraphSnapshotModel.fromJsonNullable(jsonMap), isNotNull);
      });
    });
  });
}
