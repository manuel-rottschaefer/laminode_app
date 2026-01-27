import 'package:flutter/foundation.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/services/graph_debug_service.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_providers.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_snapshot_providers.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_node_model.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'dart:math' as math;

/// Manages the visual state and synchronization of the profile graph.
class ProfileGraphController extends ChangeNotifier {
  final ForceDirectedGraphController<String> visualController;
  Ref? _ref;
  Map<String, Vector2>? _pendingPositions;

  ProfileGraphController([this._ref])
    : visualController = _createVisualController() {
    if (_ref != null) {
      _init();
    }
  }

  void setRef(Ref ref) {
    if (_ref == null) {
      _ref = ref;
      _init();
    }
  }

  Future<void> saveCurrentSnapshot() async {
    final snapshot = getSnapshot();
    if (snapshot != null && _ref != null) {
      await _ref!.read(saveGraphSnapshotUseCaseProvider).execute(snapshot);
    }
  }

  Future<void> loadSnapshot() async {
    if (_ref == null) return;
    final snapshot = await _ref!
        .read(loadGraphSnapshotUseCaseProvider)
        .execute();
    if (snapshot != null) {
      applySnapshot(snapshot);
    }
  }

  GraphSnapshot? getSnapshot() {
    if (_ref == null) return null;

    final branchedNames = _ref!.read(paramPanelProvider).branchedParamNames;

    final nodes = visualController.graph.nodes.map((n) {
      return GraphNodeModel(
        id: n.data,
        label: n.data,
        shape: GraphNodeShape.none,
        position: n.position,
        isBranching: branchedNames.contains(n.data),
      );
    }).toList();

    return GraphSnapshot(nodes: nodes);
  }

  void applySnapshot(GraphSnapshot snapshot) {
    if (_ref == null) return;

    // 1. Store positions for immediate application during sync
    _pendingPositions = {
      for (var n in snapshot.nodes)
        if (n.position != null) n.id: n.position!,
    };

    // Force edge recreation to prevent stale visual cache
    visualController.graph.edges.clear();
    visualController.needUpdate();

    // 2. Restore branching state first (this will trigger graph sync)
    final branchedNames = snapshot.nodes
        .where((n) => n.isBranching)
        .map((n) => n.id)
        .toSet();

    _ref!
        .read(paramPanelProvider.notifier)
        .setBranchedParamNames(branchedNames);

    // 3. Optional: fallback if sync didn't happen or didn't use all positions
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_pendingPositions != null) {
        _applyPendingPositions();
      }
    });
  }

  void _applyPendingPositions() {
    if (_pendingPositions == null) return;

    bool changed = false;
    final keysToRemove = <String>[];

    for (final node in visualController.graph.nodes) {
      final savedPos = _pendingPositions![node.data];
      if (savedPos != null) {
        node.position = savedPos;
        changed = true;
        keysToRemove.add(node.data);
      }
    }

    if (changed) {
      visualController.needUpdate();
    }

    for (final key in keysToRemove) {
      _pendingPositions!.remove(key);
    }

    if (_pendingPositions!.isEmpty) {
      _pendingPositions = null;
    }
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
    _ref?.listen<GraphData>(graphDataProvider, (previous, next) {
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
    final nodesWithPendingPositions = <String>{};

    for (final id in toAdd) {
      final initialPos = _pendingPositions?[id];
      visualController.addNode(id, initialPosition: initialPos);

      if (initialPos != null) {
        nodesWithPendingPositions.add(id);
        _pendingPositions!.remove(id);
      }
    }

    // 3. Position new nodes (only those explicitly added without a fixed position)
    final nodesToAutoPosition = toAdd.difference(nodesWithPendingPositions);
    if (nodesToAutoPosition.isNotEmpty) {
      _positionNewNodes(nodesToAutoPosition, next);
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
      if (_pendingPositions != null) {
        _applyPendingPositions();
      }
      visualController.needUpdate();
    }
  }

  void center() {
    visualController.center();
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
