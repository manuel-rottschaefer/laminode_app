import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/graph/hex/hex_painter.dart';
import 'package:laminode_app/core/presentation/widgets/graph/shape_utils.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_calculator.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/profile_graph_config.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_providers.dart';
import 'param_node_layout_helper.dart';
import 'param_node_builders.dart';

class ParamNodeWidget extends ConsumerStatefulWidget {
  final ParamGraphNode node;
  final VoidCallback? onTap;

  const ParamNodeWidget({super.key, required this.node, this.onTap});

  @override
  ConsumerState<ParamNodeWidget> createState() => _ParamNodeWidgetState();
}

class _ParamNodeWidgetState extends ConsumerState<ParamNodeWidget> {
  dynamic _layoutData;

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
            newNode.parameter.category.categoryColorName ||
        oldNode.isLocked != newNode.isLocked ||
        oldNode.isBranching != newNode.isBranching ||
        oldNode.hasChildren != newNode.hasChildren ||
        oldNode.level != newNode.level;
  }

  void _computeLayout() {
    final baseColor = ParamNodeLayoutHelper.getCategoryColor(
      widget.node.parameter.category.categoryColorName,
    );
    const double edgeLength = ProfileGraphConfig.baseEdgeLength;
    final int level = widget.node.level;

    _layoutData = NodeLayoutCalculator.computeHex(
      title: widget.node.parameter.paramTitle,
      edgeLength: edgeLength,
      level: level,
      cornerRadiusFactor: ProfileGraphConfig.cornerRadiusFactorHex,
      titleStyle: ParamNodeLayoutHelper.getTitleStyle(context),
      context: context,
      baseColor: baseColor,
      isFocused: widget.node.isFocused,
      id: widget.node.id,
      topmostLayerName: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_layoutData == null) _computeLayout();

    final data = _layoutData as HexNodeLayoutData;
    // Path for the painter
    final paintPath = ShapePathUtils.getHexPath(
      data.hexSize,
      strokeWidth: data.borderWidth,
      cornerRadius: data.cornerRadius,
      scaleY: ProfileGraphConfig.hexScaleY,
    );
    // Path for clipping (inner edge)
    final clipPath = ShapePathUtils.getHexPath(
      data.hexSize,
      strokeWidth: data.borderWidth + data.borderWidth / 2,
      cornerRadius: data.cornerRadius,
      scaleY: ProfileGraphConfig.hexScaleY,
    );

    return _buildNodeContainer(
      size: data.hexSize,
      painter: HexPainter(
        path: paintPath,
        fillCenter: data.centerColor,
        fillEdge: data.edgeColor,
        stroke: data.borderColor,
        strokeWidth: data.borderWidth,
        cornerRadius: data.cornerRadius,
        scaleY: ProfileGraphConfig.hexScaleY,
      ),
      path: clipPath,
      child: HexNodeBody(
        data: data,
        node: widget.node,
        focusedInputKey: widget.node.isFocused
            ? ref.watch(focusedInputKeyProvider)
            : null,
        onToggleLock: () {
          ref.read(paramPanelProvider.notifier).toggleLock(widget.node.id);
        },
        onToggleBranching: () {
          ref.read(paramPanelProvider.notifier).toggleBranching(widget.node.id);
        },
      ),
    );
  }

  Widget _buildNodeContainer({
    required Size size,
    required CustomPainter painter,
    required Path path,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: widget.onTap,
      child: CustomPaint(
        size: size,
        painter: painter,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: ClipPath(
            clipper: _ShapeClipper(path: path),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _ShapeClipper extends CustomClipper<Path> {
  final Path path;

  _ShapeClipper({required this.path});

  @override
  Path getClip(Size size) => path;

  @override
  bool shouldReclip(covariant _ShapeClipper oldClipper) =>
      oldClipper.path != path;
}
