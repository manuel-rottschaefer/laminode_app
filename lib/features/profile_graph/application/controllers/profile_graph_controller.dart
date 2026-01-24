import 'package:flutter/foundation.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math' as math;
import '../../domain/entities/graph_data.dart';
import '../providers/graph_providers.dart';
import '../../../../core/services/graph_debug_service.dart';

/// Manages the visual state and synchronization of the profile graph.
class ProfileGraphController extends ChangeNotifier {
  final ForceDirectedGraphController<String> visualController;
  final Ref _ref;

  ProfileGraphController(this._ref)
    : visualController = _createVisualController() {
    _init();
  }

  static ForceDirectedGraphController<String> _createVisualController() {
    final cfg = GraphConfig(
      length: 220,
      repulsion: 180,
      repulsionRange: 350,
      centerGravity: 0.1,
    );
    final graph = ForceDirectedGraph<String>(config: cfg);
    return ForceDirectedGraphController<String>(graph: graph);
  }

  void _init() {
    _ref.listen<GraphData>(graphDataProvider, (previous, next) {
      _syncGraph(previous, next);
    }, fireImmediately: true);
  }

  void _syncGraph(GraphData? previous, GraphData next) {
    if (next.isEmpty) {
      GraphDebugService.logCleared(previous: previous);
      visualController.graph.nodes.clear();
      visualController.graph.edges.clear();
      visualController.needUpdate();
      return;
    }

    final currentNodes = visualController.graph.nodes
        .map((n) => n.data)
        .toSet();
    final desiredNodes = next.nodes.keys.toSet();

    // 1. Remove old nodes
    final toRemove = currentNodes.difference(desiredNodes);
    for (final id in toRemove) {
      visualController.deleteNodeByData(id);
    }

    // 2. Add new nodes
    final toAdd = desiredNodes.difference(currentNodes);
    for (final id in toAdd) {
      visualController.addNode(id);
    }

    // 3. Position new nodes
    if (toAdd.isNotEmpty) {
      _positionNewNodes(toAdd, next);
    }

    // 4. Sync Edges
    final currentEdges = visualController.graph.edges
        .map((e) => '${e.a.data}|${e.b.data}')
        .toSet();
    final desiredEdges = next.edges.map((e) => e.id).toSet();

    final edgesToAdd = desiredEdges.difference(currentEdges);
    for (final edgeId in edgesToAdd) {
      final parts = edgeId.split('|');
      visualController.addEdgeByData(parts[0], parts[1]);
    }

    final edgesToRemove = currentEdges.difference(desiredEdges);

    GraphDebugService.logSyncSummary(
      current: next,
      previous: previous,
      addedNodes: toAdd,
      removedNodes: toRemove,
      addedEdges: edgesToAdd,
      removedEdges: edgesToRemove,
    );
    for (final edgeId in edgesToRemove) {
      final parts = edgeId.split('|');
      visualController.deleteEdgeByData(parts[0], parts[1]);
    }

    if (toRemove.isNotEmpty ||
        toAdd.isNotEmpty ||
        edgesToAdd.isNotEmpty ||
        edgesToRemove.isNotEmpty) {
      visualController.needUpdate();
    }
  }

  void _positionNewNodes(Set<String> newIds, GraphData data) {
    // Optimization: Create a map for fast lookup of existing nodes
    final nodeMap = {for (var n in visualController.graph.nodes) n.data: n};

    // Group new nodes by their parent
    final nodesByParent = <String, List<String>>{};
    for (final id in newIds) {
      if (data.nodes[id] == null) continue;

      // Find a visible parent in the graph
      String? parentId;
      for (final edge in data.edges) {
        if (edge.targetId == id && data.nodes.containsKey(edge.sourceId)) {
          parentId = edge.sourceId;
          break;
        }
      }

      if (parentId != null) {
        nodesByParent.putIfAbsent(parentId, () => []).add(id);
      } else {
        nodesByParent.putIfAbsent('__root__', () => []).add(id);
      }
    }

    // Position root-level nodes in a large circle
    final roots = nodesByParent['__root__'] ?? [];
    if (roots.isNotEmpty) {
      final radius = visualController.graph.config.length * 2.5;
      for (var i = 0; i < roots.length; i++) {
        final node = nodeMap[roots[i]];
        if (node != null) {
          final angle = (i * 2 * math.pi) / roots.length;
          node.position = Vector2(
            radius * math.cos(angle),
            radius * math.sin(angle),
          );
        }
      }
    }

    // Position children around their parents
    for (final parentId in nodesByParent.keys) {
      if (parentId == '__root__') continue;
      _positionChildrenAround(parentId, nodesByParent[parentId]!, nodeMap);
    }
  }

  void _positionChildrenAround(
    String parentId,
    List<String> childrenIds,
    Map<String, Node<String>> nodeMap,
  ) {
    final parentNode = nodeMap[parentId];
    if (parentNode == null) return;

    final radius = visualController.graph.config.length * 0.7;
    final startAngle = (parentId.hashCode % 360) * (math.pi / 180.0);

    for (var i = 0; i < childrenIds.length; i++) {
      final node = nodeMap[childrenIds[i]];
      if (node != null) {
        final angle = startAngle + (i * 2 * math.pi) / childrenIds.length;
        node.position = Vector2(
          parentNode.position.x + radius * math.cos(angle),
          parentNode.position.y + radius * math.sin(angle),
        );
      }
    }
  }
}
