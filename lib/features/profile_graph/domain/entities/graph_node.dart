import 'package:laminode_app/core/domain/entities/cam_param.dart';

enum GraphNodeShape { none, hex, octagon }

abstract class GraphNode {
  final String id;
  final String label;
  final GraphNodeShape shape;
  final int level;
  final bool isSelected;
  final bool isFocused;
  final bool isLocked;
  final bool isBranching;
  final bool hasChildren;

  const GraphNode({
    required this.id,
    required this.label,
    required this.shape,
    this.level = 0,
    this.isSelected = false,
    this.isFocused = false,
    this.isLocked = false,
    this.isBranching = false,
    this.hasChildren = false,
  });

  GraphNode copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    int? level,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
    bool? hasChildren,
  });
}

class RootGraphNode extends GraphNode {
  const RootGraphNode({
    required super.id,
    required super.label,
    super.level = -1,
    super.isSelected,
    super.isFocused,
    super.isLocked,
    super.isBranching = true,
    super.hasChildren = true,
  }) : super(shape: GraphNodeShape.none);

  @override
  RootGraphNode copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    int? level,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
    bool? hasChildren,
  }) {
    return RootGraphNode(
      id: id ?? this.id,
      label: label ?? this.label,
      level: level ?? this.level,
      isSelected: isSelected ?? this.isSelected,
      isFocused: isFocused ?? this.isFocused,
      isLocked: isLocked ?? this.isLocked,
      isBranching: isBranching ?? this.isBranching,
      hasChildren: hasChildren ?? this.hasChildren,
    );
  }
}

class HubGraphNode extends GraphNode {
  final CamParamCategory category;

  const HubGraphNode({
    required super.id,
    required super.label,
    required this.category,
    super.level = -1,
    super.isSelected,
    super.isFocused,
    super.isLocked,
    super.isBranching = true,
    super.hasChildren = true,
  }) : super(shape: GraphNodeShape.octagon);

  @override
  HubGraphNode copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    int? level,
    CamParamCategory? category,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
    bool? hasChildren,
  }) {
    return HubGraphNode(
      id: id ?? this.id,
      label: label ?? this.label,
      category: category ?? this.category,
      level: level ?? this.level,
      isSelected: isSelected ?? this.isSelected,
      isFocused: isFocused ?? this.isFocused,
      isLocked: isLocked ?? this.isLocked,
      isBranching: isBranching ?? this.isBranching,
      hasChildren: hasChildren ?? this.hasChildren,
    );
  }
}

class ParamGraphNode extends GraphNode {
  final CamParameter parameter;

  const ParamGraphNode({
    required super.id,
    required super.label,
    required this.parameter,
    super.level = 0,
    super.isSelected,
    super.isFocused,
    super.isLocked,
    super.isBranching = false,
    super.hasChildren = false,
  }) : super(shape: GraphNodeShape.hex);

  @override
  ParamGraphNode copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    int? level,
    CamParameter? parameter,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
    bool? hasChildren,
  }) {
    return ParamGraphNode(
      id: id ?? this.id,
      label: label ?? this.label,
      parameter: parameter ?? this.parameter,
      level: level ?? this.level,
      isSelected: isSelected ?? this.isSelected,
      isFocused: isFocused ?? this.isFocused,
      isLocked: isLocked ?? this.isLocked,
      isBranching: isBranching ?? this.isBranching,
      hasChildren: hasChildren ?? this.hasChildren,
    );
  }
}
