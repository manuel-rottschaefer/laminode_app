import '../../domain/entities/graph_snapshot.dart';
import 'graph_node_model.dart';

class GraphSnapshotModel extends GraphSnapshot {
  const GraphSnapshotModel({
    super.nodes = const [],
  });

  factory GraphSnapshotModel.fromEntity(GraphSnapshot entity) {
    return GraphSnapshotModel(
      nodes: entity.nodes.map((e) => GraphNodeModel.fromEntity(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodes': nodes.map((e) {
        if (e is GraphNodeModel) {
          return e.toJson();
        }
        return GraphNodeModel.fromEntity(e).toJson();
      }).toList(),
    };
  }

  factory GraphSnapshotModel.fromJson(Map<String, dynamic> json) {
    return GraphSnapshotModel(
      nodes: (json['nodes'] as List<dynamic>?)
              ?.map((e) => GraphNodeModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static GraphSnapshotModel? fromJsonNullable(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      return GraphSnapshotModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
