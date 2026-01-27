import 'graph_node.dart';
import 'package:vector_math/vector_math_64.dart';

class GraphSnapshot {
  final List<GraphNode> nodes;
  final Map<String, Vector2> nodePositions;
  final List<String> branchedParamNames;

  const GraphSnapshot({
    this.nodes = const [],
    this.nodePositions = const {},
    this.branchedParamNames = const [],
  });

  GraphSnapshot copyWith({
    List<GraphNode>? nodes,
    Map<String, Vector2>? nodePositions,
    List<String>? branchedParamNames,
  }) {
    return GraphSnapshot(
      nodes: nodes ?? this.nodes,
      nodePositions: nodePositions ?? this.nodePositions,
      branchedParamNames: branchedParamNames ?? this.branchedParamNames,
    );
  }
}
