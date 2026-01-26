import 'package:vector_math/vector_math_64.dart';

class GraphSnapshot {
  final Map<String, Vector2> nodePositions;
  final Set<String> branchedParamNames;

  const GraphSnapshot({
    this.nodePositions = const {},
    this.branchedParamNames = const {},
  });

  GraphSnapshot copyWith({
    Map<String, Vector2>? nodePositions,
    Set<String>? branchedParamNames,
  }) {
    return GraphSnapshot(
      nodePositions: nodePositions ?? this.nodePositions,
      branchedParamNames: branchedParamNames ?? this.branchedParamNames,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodePositions': nodePositions.map(
        (key, value) => MapEntry(key, [value.x, value.y]),
      ),
      'branchedParamNames': branchedParamNames.toList(),
    };
  }

  factory GraphSnapshot.fromJson(Map<String, dynamic> json) {
    return GraphSnapshot(
      nodePositions: (json['nodePositions'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          Vector2((value[0] as num).toDouble(), (value[1] as num).toDouble()),
        ),
      ),
      branchedParamNames: (json['branchedParamNames'] as List<dynamic>)
          .map((e) => e as String)
          .toSet(),
    );
  }

  static GraphSnapshot? fromJsonNullable(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      return GraphSnapshot.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
