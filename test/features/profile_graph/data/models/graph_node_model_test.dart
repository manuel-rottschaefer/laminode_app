import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_node_model.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  group('GraphNodeModel', () {
    const tId = 'node_1';
    final tPosition = Vector2(10.0, 20.0);
    const tIsBranching = true;
    
    final tGraphNodeModel = GraphNodeModel(
      id: tId,
      label: 'test_label', // Not serialized
      shape: GraphNodeShape.hex, // Not serialized
      isBranching: tIsBranching,
      position: tPosition,
    );

    test('should be a subclass of GraphNode', () {
      expect(tGraphNodeModel, isA<GraphNode>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON contains all fields', () {
        final Map<String, dynamic> jsonMap = {
          'id': tId,
          'position': [10.0, 20.0],
          'isBranching': tIsBranching,
        };

        final result = GraphNodeModel.fromJson(jsonMap);

        expect(result.id, tId);
        expect(result.position!.x, 10.0);
        expect(result.position!.y, 20.0);
        expect(result.isBranching, tIsBranching);
        // Defaults
        expect(result.label, '');
        expect(result.shape, GraphNodeShape.none);
      });

      test('should return a valid model when position is null', () {
        final Map<String, dynamic> jsonMap = {
          'id': tId,
        };

        final result = GraphNodeModel.fromJson(jsonMap);

        expect(result.id, tId);
        expect(result.position, isNull);
        expect(result.isBranching, false); // Default
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        final result = tGraphNodeModel.toJson();

        final expectedMap = {
          'id': tId,
          'position': [10.0, 20.0],
          'isBranching': tIsBranching,
        };

        expect(result, expectedMap);
      });

      test('should return a JSON map with null position when position is null', () {
        const tNode = GraphNodeModel(
          id: tId,
          label: '',
          shape: GraphNodeShape.none,
          position: null,
        );
        
        final result = tNode.toJson();

        expect(result['position'], null);
      });
    });

    group('fromEntity', () {
      test('should return a valid model from entity', () {
        final tEntity = GraphNodeModel(
          id: tId,
          label: 'label',
          shape: GraphNodeShape.octagon,
          level: 1,
          isSelected: true,
          isFocused: true,
          isLocked: true,
          isBranching: true,
          hasChildren: true,
          position: tPosition,
        );

        final result = GraphNodeModel.fromEntity(tEntity);

        expect(result.id, tEntity.id);
        expect(result.label, tEntity.label);
        expect(result.shape, tEntity.shape);
        expect(result.level, tEntity.level);
        expect(result.isSelected, tEntity.isSelected);
        expect(result.isFocused, tEntity.isFocused);
        expect(result.isLocked, tEntity.isLocked);
        expect(result.isBranching, tEntity.isBranching);
        expect(result.hasChildren, tEntity.hasChildren);
        expect(result.position, tEntity.position);
      });
    });
    
    group('copyWith', () {
      test('should return a copy with updated fields', () {
        final updated = tGraphNodeModel.copyWith(label: 'new_label');
        expect(updated.label, 'new_label');
        expect(updated.id, tGraphNodeModel.id);
      });
    });
  });
}
