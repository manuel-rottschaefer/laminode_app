import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_providers.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/profile_graph_config.dart';
import 'graph_node_widget.dart';
import 'param_node_layout_helper.dart';

class ProfileGraphNodesBuilder extends ConsumerWidget {
  final String id;
  final VoidCallback? onNodeTap;

  const ProfileGraphNodesBuilder({super.key, required this.id, this.onNodeTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphData = ref.watch(graphDataProvider);
    final nodeData = graphData.nodes[id];

    if (nodeData == null) return const SizedBox.shrink();

    return GraphNodeWidget(node: nodeData, onTap: onNodeTap);
  }
}

class ProfileGraphEdgesBuilder extends ConsumerWidget {
  final String a;
  final String b;
  final double distance;
  final ForceDirectedGraphController<String> visualController;

  const ProfileGraphEdgesBuilder({
    super.key,
    required this.a,
    required this.b,
    required this.distance,
    required this.visualController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final graphData = ref.watch(graphDataProvider);
    final nodeA = graphData.nodes[a];
    final nodeB = graphData.nodes[b];

    if (nodeA == null || nodeB == null) {
      return const SizedBox.shrink();
    }

    // Determine colors
    Color getColor(GraphNode node) {
      if (node is ParamGraphNode) {
        return ParamNodeLayoutHelper.getCategoryColor(
          node.parameter.category.categoryColorName,
        );
      } else if (node is HubGraphNode) {
        return ParamNodeLayoutHelper.getCategoryColor(
          node.category.categoryColorName,
        );
      }
      return ProfileGraphConfig.rootEdgeColor;
    }

    Color colorA = getColor(nodeA);
    Color colorB = getColor(nodeB);

    // Adjust for gradient direction based on X position
    bool leftIsA = true;
    try {
      final vNodeA = visualController.graph.nodes.firstWhere(
        (n) => n.data == a,
      );
      final vNodeB = visualController.graph.nodes.firstWhere(
        (n) => n.data == b,
      );
      leftIsA = vNodeA.position.x <= vNodeB.position.x;
    } catch (_) {}

    // Apply level-based darkening
    colorA = ParamNodeLayoutHelper.darken(colorA, nodeA.level);
    colorB = ParamNodeLayoutHelper.darken(colorB, nodeB.level);

    final leftColor = leftIsA ? colorA : colorB;
    final rightColor = leftIsA ? colorB : colorA;

    final bool isRootEdge = nodeA is RootGraphNode || nodeA is HubGraphNode;
    final double currentEdgeWidth = isRootEdge
        ? ProfileGraphConfig.rootEdgeWidth
        : ProfileGraphConfig.edgeWidth;

    return Container(
      width: distance,
      height: currentEdgeWidth,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [leftColor, rightColor]),
        borderRadius: BorderRadius.circular(currentEdgeWidth / 2),
      ),
    );
  }
}
