import 'package:laminode_app/core/domain/entities/cam_param.dart';

enum GraphNodeShape { none, hex, octagon }

abstract class GraphNode {
  final String id;
  final String label;
  final GraphNodeShape shape;
  final bool isSelected;
  final bool isFocused;
  final bool isLocked;
  final bool isBranching;

  const GraphNode({
    required this.id,
    required this.label,
    required this.shape,
    this.isSelected = false,
    this.isFocused = false,
    this.isLocked = false,
    this.isBranching = false,
  });

  GraphNode copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
  });
}

class RootGraphNode extends GraphNode {
  const RootGraphNode({
    required super.id,
    required super.label,
    super.isSelected,
    super.isFocused,
    super.isLocked,
    super.isBranching = true,
  }) : super(shape: GraphNodeShape.none);

  @override
  RootGraphNode copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
  }) {
    return RootGraphNode(
      id: id ?? this.id,
      label: label ?? this.label,
      isSelected: isSelected ?? this.isSelected,
      isFocused: isFocused ?? this.isFocused,
      isLocked: isLocked ?? this.isLocked,
      isBranching: isBranching ?? this.isBranching,
    );
  }
}

class HubGraphNode extends GraphNode {
  final CamParamCategory category;

  const HubGraphNode({
    required super.id,
    required super.label,
    required this.category,
    super.isSelected,
    super.isFocused,
    super.isLocked,
    super.isBranching = false,
  }) : super(shape: GraphNodeShape.octagon);

  @override
  HubGraphNode copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    CamParamCategory? category,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
  }) {
    return HubGraphNode(
      id: id ?? this.id,
      label: label ?? this.label,
      category: category ?? this.category,
      isSelected: isSelected ?? this.isSelected,
      isFocused: isFocused ?? this.isFocused,
      isLocked: isLocked ?? this.isLocked,
      isBranching: isBranching ?? this.isBranching,
    );
  }
}

class ParamGraphNode extends GraphNode {
  final CamParameter parameter;

  const ParamGraphNode({
    required super.id,
    required super.label,
    required this.parameter,
    super.isSelected,
    super.isFocused,
    super.isLocked,
    super.isBranching = false,
  }) : super(shape: GraphNodeShape.hex);

  @override
  ParamGraphNode copyWith({
    String? id,
    String? label,
    GraphNodeShape? shape,
    CamParameter? parameter,
    bool? isSelected,
    bool? isFocused,
    bool? isLocked,
    bool? isBranching,
  }) {
    return ParamGraphNode(
      id: id ?? this.id,
      label: label ?? this.label,
      parameter: parameter ?? this.parameter,
      isSelected: isSelected ?? this.isSelected,
      isFocused: isFocused ?? this.isFocused,
      isLocked: isLocked ?? this.isLocked,
      isBranching: isBranching ?? this.isBranching,
    );
  }
}
