import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:vector_math/vector_math_64.dart';

class GraphNodeModel extends GraphNode {
  const GraphNodeModel({
    required super.id,
    required super.label,
    required super.shape,
    super.level,
    super.isSelected,
    super.isFocused,
    super.isLocked,
    super.isBranching,
    super.hasChildren,
    super.position,
  });

  factory GraphNodeModel.fromEntity(GraphNode entity) {
    return GraphNodeModel(
      id: entity.id,
      label: entity.label,
      shape: entity.shape,
      level: entity.level,
      isSelected: entity.isSelected,
      isFocused: entity.isFocused,
      isLocked: entity.isLocked,
      isBranching: entity.isBranching,
      hasChildren: entity.hasChildren,
      position: entity.position,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position != null ? [position!.x, position!.y] : null,
      'isBranching': isBranching,
    };
  }

  factory GraphNodeModel.fromJson(Map<String, dynamic> json) {
    final posJson = json['position'] as List<dynamic>?;
    final position = posJson != null
        ? Vector2(
            (posJson[0] as num).toDouble(),
            (posJson[1] as num).toDouble(),
          )
        : null;

    return GraphNodeModel(
      id: json['id'] as String,
      label: '', // Determined by graph feature
      shape: GraphNodeShape.none, // Determined by graph feature
      isBranching: json['isBranching'] as bool? ?? false,
      position: position,
    );
  }

  @override
  GraphNodeModel copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    int? level,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
    bool? hasChildren,
    Vector2? position,
  }) {
    return GraphNodeModel(
      id: id ?? this.id,
      label: label ?? this.label,
      shape: shape ?? this.shape,
      level: level ?? this.level,
      isSelected: isSelected ?? this.isSelected,
      isFocused: isFocused ?? this.isFocused,
      isLocked: isLocked ?? this.isLocked,
      isBranching: isBranching ?? this.isBranching,
      hasChildren: hasChildren ?? this.hasChildren,
      position: position ?? this.position,
    );
  }
}
