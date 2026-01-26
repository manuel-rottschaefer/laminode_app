import 'package:flutter/material.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'root_node_widget.dart';
import 'hub_node_widget.dart';
import 'param_node_widget.dart';

class GraphNodeWidget extends StatelessWidget {
  final GraphNode node;
  final VoidCallback? onTap;

  const GraphNodeWidget({super.key, required this.node, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (node is RootGraphNode) {
      return RootNodeWidget(node: node as RootGraphNode, onTap: onTap);
    } else if (node is HubGraphNode) {
      return HubNodeWidget(node: node as HubGraphNode, onTap: onTap);
    } else if (node is ParamGraphNode) {
      return ParamNodeWidget(node: node as ParamGraphNode, onTap: onTap);
    }
    return const SizedBox.shrink();
  }
}
