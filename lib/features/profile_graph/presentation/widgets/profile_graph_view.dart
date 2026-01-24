import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/providers/graph_providers.dart';
import '../../../param_panel/presentation/providers/param_panel_provider.dart';
import '../../domain/entities/graph_node.dart';
import 'graph_node_widget.dart';

class ProfileGraphView extends ConsumerWidget {
  const ProfileGraphView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visualController = ref
        .watch(profileGraphControllerProvider)
        .visualController;

    return ForceDirectedGraphWidget<String>(
      controller: visualController,
      nodesBuilder: (context, id) {
        final graphData = ref.watch(graphDataProvider);
        final nodeData = graphData.nodes[id];

        if (nodeData == null) return const SizedBox.shrink();

        return GraphNodeWidget(
          node: nodeData,
          onTap: () {
            if (nodeData is ParamGraphNode) {
              ref
                  .read(paramPanelProvider.notifier)
                  .toggleExpansion(nodeData.id);
            }
          },
        );
      },
      edgesBuilder: (context, a, b, distance) {
        return Container(
          width: distance,
          height: 1.5,
          color: Colors.grey.withValues(alpha: 0.2),
        );
      },
    );
  }
}
