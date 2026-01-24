import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/graph/hex/hex_painter.dart';
import 'package:laminode_app/core/presentation/widgets/graph/octagon/octagon_painter.dart';
import '../../domain/entities/graph_node.dart';
import '../utils/node_layout_calculator.dart';
import 'param_node_action_bar.dart';
import 'param_node_layout_helper.dart';
import 'param_node_builders.dart';

class ParamNodeWidget extends StatefulWidget {
  final ParamGraphNode node;
  final VoidCallback? onTap;

  const ParamNodeWidget({super.key, required this.node, this.onTap});

  @override
  State<ParamNodeWidget> createState() => _ParamNodeWidgetState();
}

class _ParamNodeWidgetState extends State<ParamNodeWidget> {
  dynamic _layoutData;
  late GraphNodeShape _cachedShape;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _computeLayout();
  }

  @override
  void didUpdateWidget(covariant ParamNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRecomputeLayout(oldWidget.node, widget.node)) {
      _computeLayout();
    }
  }

  bool _shouldRecomputeLayout(ParamGraphNode oldNode, ParamGraphNode newNode) {
    return oldNode.parameter.paramTitle != newNode.parameter.paramTitle ||
        oldNode.shape != newNode.shape ||
        oldNode.isFocused != newNode.isFocused ||
        oldNode.isSelected != newNode.isSelected ||
        oldNode.parameter.category.categoryColorName !=
            newNode.parameter.category.categoryColorName;
  }

  void _computeLayout() {
    _cachedShape = widget.node.shape;
    final baseColor = ParamNodeLayoutHelper.getCategoryColor(
      widget.node.parameter.category.categoryColorName,
    );
    const double edgeLength = 140.0;
    const int level = 0;

    if (widget.node.shape == GraphNodeShape.octagon) {
      _layoutData = NodeLayoutCalculator.computeOctagon(
        title: widget.node.parameter.paramTitle,
        edgeLength: edgeLength,
        level: level,
        cornerRadiusFactor: 0.1,
        titleStyle: ParamNodeLayoutHelper.titleStyle,
        context: context,
        baseColor: baseColor,
        isFocused: widget.node.isFocused,
        id: widget.node.id,
        topmostLayerName: null,
        flatBackground: false,
      );
    } else {
      _layoutData = NodeLayoutCalculator.computeHex(
        title: widget.node.parameter.paramTitle,
        edgeLength: edgeLength,
        level: level,
        cornerRadiusFactor: 0.15,
        titleStyle: ParamNodeLayoutHelper.titleStyle,
        context: context,
        baseColor: baseColor,
        isFocused: widget.node.isFocused,
        id: widget.node.id,
        topmostLayerName: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_layoutData == null) _computeLayout();

    if (_cachedShape == GraphNodeShape.octagon) {
      final data = _layoutData as OctagonNodeLayoutData;
      return _buildNodeContainer(
        size: data.nodeSize,
        painter: OctagonPainter(
          fillCenter: data.centerColor,
          fillEdge: data.edgeColor,
          stroke: data.borderColor,
          strokeWidth: data.borderWidth,
          cornerRadius: data.cornerRadius,
          rotationDegrees: 22.5,
        ),
        child: OctagonNodeBody(data: data, node: widget.node),
      );
    }
    final data = _layoutData as HexNodeLayoutData;
    return _buildNodeContainer(
      size: data.hexSize,
      painter: HexPainter(
        fillCenter: data.centerColor,
        fillEdge: data.edgeColor,
        stroke: data.borderColor,
        strokeWidth: data.borderWidth,
        cornerRadius: data.cornerRadius,
      ),
      child: HexNodeBody(data: data, node: widget.node),
    );
  }

  Widget _buildNodeContainer({
    required Size size,
    required CustomPainter painter,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: CustomPaint(
          size: size,
          painter: painter,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(child: child),

                if (widget.node.isFocused)
                  Positioned(
                    top: -20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ParamNodeActionBar(
                        onMoveUp: () {},
                        onMoveDown: () {},
                        onToggleLock: () {},
                        onEdit: () {},
                        onDelete: () {},
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
