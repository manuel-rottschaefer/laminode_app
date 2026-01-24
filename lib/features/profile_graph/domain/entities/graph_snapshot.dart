import 'package:vector_math/vector_math_64.dart';

class GraphSnapshot {
  final Map<String, Vector2> nodePositions;

  const GraphSnapshot({this.nodePositions = const {}});

  const GraphSnapshot.empty() : nodePositions = const {};

  GraphSnapshot copyWith({Map<String, Vector2>? nodePositions}) {
    return GraphSnapshot(nodePositions: nodePositions ?? this.nodePositions);
  }
}
