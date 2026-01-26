import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/services/graph_debug_service.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_edge.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';

class GetProfileGraphData {
  /// Computes the complete graph data (nodes and edges).
  /// [categories] are the root/hub categories to display.
  /// [parameters] are the param nodes to display.
  GraphData execute({
    required List<CamParamCategory> categories,
    required List<CamParameter> parameters,
    Map<String, List<String>>? parentToChildrenMap,
    Set<String>? branchedParamNames,
  }) {
    final nodes = <String, GraphNode>{};
    final edges = <GraphEdge>{};
    final branched = branchedParamNames ?? <String>{};

    // 0. Build reverse map for easy parent lookup
    final childToParent = <String, String>{};
    if (parentToChildrenMap != null) {
      for (final entry in parentToChildrenMap.entries) {
        for (final childId in entry.value) {
          childToParent[childId] = entry.key;
        }
      }
    }

    // 1. Create nodes for categories (Roots and Hubs)
    for (final cat in categories) {
      final nodeId = '__cat_${cat.categoryName}';
      if (cat.parentCategoryName == null || cat.parentCategoryName!.isEmpty) {
        // Root category
        nodes[nodeId] = RootGraphNode(id: nodeId, label: cat.categoryTitle);
      } else {
        // Subcategory -> Hub node
        nodes[nodeId] = HubGraphNode(
          id: nodeId,
          label: cat.categoryTitle,
          category: cat,
        );
        // Connect to parent category
        final parentNodeId = '__cat_${cat.parentCategoryName}';
        edges.add(GraphEdge(parentNodeId, nodeId));
      }
    }

    // 2. Determine visible parameters based on branching state
    final visibleParams = <String, CamParameter>{};
    final allParamsMap = {for (var p in parameters) p.paramName: p};

    GraphDebugService.talker.debug(
      'Evaluating visibility for ${parameters.length} parameters. '
      'Branched: $branched',
    );

    // Iteratively find visible parameters
    bool changed = true;
    while (changed) {
      changed = false;
      for (final param in parameters) {
        if (visibleParams.containsKey(param.paramName)) continue;

        bool isVisible = false;
        // Prefer hierarchy map over entity baseParam for consistency
        final parentId = childToParent[param.paramName] ?? param.baseParam;

        if (parentId == null || parentId.isEmpty) {
          // Roots are always visible
          isVisible = true;
        } else {
          // If parent is not in our parameter set, treat as root (visible)
          if (!allParamsMap.containsKey(parentId)) {
            isVisible = true;
          } else if (visibleParams.containsKey(parentId) &&
              branched.contains(parentId)) {
            // Visible if parent is visible AND parent is branched
            isVisible = true;
          }
        }

        if (isVisible) {
          visibleParams[param.paramName] = param;
          changed = true;
        }
      }
    }

    GraphDebugService.talker.info(
      'Visible parameters selected: ${visibleParams.keys.toList()}',
    );

    // 3. Create Param nodes for visible parameters and compute levels
    for (final param in visibleParams.values) {
      final isBranching = branched.contains(param.paramName);
      final hasChildren =
          parentToChildrenMap?.containsKey(param.paramName) ?? false;

      // Compute level based on depth in parent hierarchy
      int level = 0;
      String? currentId = childToParent[param.paramName] ?? param.baseParam;
      int safetyLimit = 20;

      while (currentId != null && currentId.isNotEmpty && safetyLimit > 0) {
        if (allParamsMap.containsKey(currentId)) {
          level++;
          currentId =
              childToParent[currentId] ?? allParamsMap[currentId]!.baseParam;
        } else {
          currentId = null;
        }
        safetyLimit--;
      }

      nodes[param.paramName] = ParamGraphNode(
        id: param.paramName,
        label: param.paramTitle,
        parameter: param,
        isBranching: isBranching,
        hasChildren: hasChildren,
        level: level,
      );
    }

    // 4. Connect parameters to their parents OR category roots
    for (final param in visibleParams.values) {
      final parentId = childToParent[param.paramName] ?? param.baseParam;

      if (parentId != null &&
          parentId.isNotEmpty &&
          nodes.containsKey(parentId)) {
        // We have a visible parent in the graph! Step 5 will handle the edge.
        continue;
      } else {
        // No visible parent or parent is outside graph, connect to category root
        final catNodeId = '__cat_${param.category.categoryName}';
        if (nodes.containsKey(catNodeId)) {
          edges.add(GraphEdge(catNodeId, param.paramName));
        }
      }
    }

    // 5. Handle hierarchical edges between parameters
    if (parentToChildrenMap != null) {
      for (final entry in parentToChildrenMap.entries) {
        final parentId = entry.key;
        if (!nodes.containsKey(parentId)) continue;

        for (final childId in entry.value) {
          // Only create edge if child is visible
          if (nodes.containsKey(childId)) {
            edges.add(GraphEdge(parentId, childId));
          }
        }
      }
    }

    return GraphData(nodes: nodes, edges: edges);
  }
}
