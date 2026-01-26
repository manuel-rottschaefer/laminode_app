import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/graph/octagon/octagon_painter.dart';
import 'package:laminode_app/core/presentation/widgets/graph/octagon/octagon_layout.dart';
import 'package:laminode_app/core/presentation/widgets/graph/shape_utils.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_calculator.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/profile_graph_config.dart';
import 'param_node_layout_helper.dart';

class HubNodeWidget extends ConsumerStatefulWidget {
  final HubGraphNode node;
  final VoidCallback? onTap;

  const HubNodeWidget({super.key, required this.node, this.onTap});

  @override
  ConsumerState<HubNodeWidget> createState() => _HubNodeWidgetState();
}

class _HubNodeWidgetState extends ConsumerState<HubNodeWidget> {
  OctagonNodeLayoutData? _layoutData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _computeLayout();
  }

  @override
  void didUpdateWidget(covariant HubNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRecomputeLayout(oldWidget.node, widget.node)) {
      _computeLayout();
    }
  }

  bool _shouldRecomputeLayout(HubGraphNode oldNode, HubGraphNode newNode) {
    return oldNode.label != newNode.label ||
        oldNode.isFocused != newNode.isFocused ||
        oldNode.category.categoryColorName !=
            newNode.category.categoryColorName ||
        oldNode.level != newNode.level;
  }

  void _computeLayout() {
    final baseColor = ParamNodeLayoutHelper.getCategoryColor(
      widget.node.category.categoryColorName,
    );
    const double edgeLength = ProfileGraphConfig.baseEdgeLength;
    final int level = widget.node.level;

    _layoutData = NodeLayoutCalculator.computeOctagon(
      title: widget.node.label,
      edgeLength: edgeLength,
      level: level,
      cornerRadiusFactor: 0.1,
      titleStyle: ParamNodeLayoutHelper.getTitleStyle(context),
      context: context,
      baseColor: baseColor,
      isFocused: widget.node.isFocused,
      id: widget.node.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_layoutData == null) _computeLayout();
    final data = _layoutData!;

    final paintPath = ShapePathUtils.getOctagonPath(
      data.nodeSize,
      strokeWidth: data.borderWidth,
      cornerRadius: data.cornerRadius,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: CustomPaint(
        size: data.nodeSize,
        painter: OctagonPainter(
          path: paintPath,
          fillCenter: data.centerColor,
          fillEdge: data.edgeColor,
          stroke: data.borderColor,
          strokeWidth: data.borderWidth,
          cornerRadius: data.cornerRadius,
        ),
        child: OctagonLayout(
          circumradius: data.circumradius,
          children: [
            OctagonChild(
              anchor: OctagonAnchor.center,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Text(
                  widget.node.label,
                  textAlign: TextAlign.center,
                  style: ParamNodeLayoutHelper.getTitleStyle(
                    context,
                  ).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
