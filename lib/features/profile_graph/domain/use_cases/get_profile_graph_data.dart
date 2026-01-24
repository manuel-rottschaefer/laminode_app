import '../entities/graph_data.dart';
import '../entities/graph_node.dart';
import '../entities/graph_edge.dart';
import '../../../../core/domain/entities/cam_param.dart';

class GetProfileGraphData {
  /// Computes the complete graph data (nodes and edges).
  /// [categories] are the root/hub categories to display.
  /// [parameters] are the param nodes to display.
  GraphData execute({
    required List<CamParamCategory> categories,
    required List<CamParameter> parameters,
    Map<String, List<String>>? parentToChildrenMap,
  }) {
    final nodes = <String, GraphNode>{};
    final edges = <GraphEdge>{};

    // 1. Create Root nodes for base categories
    // For now we assume all provided categories are roots.
    // In a more complex scenario, we would distinguish roots from hubs.
    for (final cat in categories) {
      final nodeId = '__root_${cat.categoryName}';
      nodes[nodeId] = RootGraphNode(id: nodeId, label: cat.categoryTitle);
    }

    // 2. Create Param nodes
    for (final param in parameters) {
      nodes[param.paramName] = ParamGraphNode(
        id: param.paramName,
        label: param.paramTitle,
        parameter: param,
      );
    }

    // 3. Connect parameters to their respective category roots if they have no parent
    for (final param in parameters) {
      // Connect to root only if it has no parent relation
      if (param.baseParam == null || param.baseParam!.isEmpty) {
        final catNodeId = '__root_${param.category.categoryName}';
        if (nodes.containsKey(catNodeId)) {
          edges.add(GraphEdge(catNodeId, param.paramName));
        }
      }
    }

    // 4. Handle hierarchical edges between parameters if provided
    if (parentToChildrenMap != null) {
      for (final entry in parentToChildrenMap.entries) {
        final parentId = entry.key;
        // The parent must exist in our node set (might be missing if it's from an inactive layer)
        if (!nodes.containsKey(parentId)) continue;

        for (final childId in entry.value) {
          if (nodes.containsKey(childId)) {
            edges.add(GraphEdge(parentId, childId));

            // Ensure the child is not also connected to the root category
            // (though skip above should have handled it if baseParam was set)
            final node = nodes[childId];
            if (node is ParamGraphNode) {
              final catNodeId =
                  '__root_${node.parameter.category.categoryName}';
              edges.removeWhere((e) => e.id == '$catNodeId|$childId');
            }
          }
        }
      }
    }

    return GraphData(nodes: nodes, edges: edges);
  }
}
