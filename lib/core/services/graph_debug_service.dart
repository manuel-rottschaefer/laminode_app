import 'package:talker/talker.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';

/// Centralized graph debugging helper backed by [talker].
class GraphDebugService {
  static final Talker talker = Talker();

  static void logSyncSummary({
    required GraphData current,
    GraphData? previous,
    required Set<String> addedNodes,
    required Set<String> removedNodes,
    required Set<String> addedEdges,
    required Set<String> removedEdges,
  }) {
    final prevNodeCount = previous?.nodes.length ?? 0;
    final prevEdgeCount = previous?.edges.length ?? 0;
    talker.info(
      'Graph sync -> nodes: ${current.nodes.length} (+${addedNodes.length}, -${removedNodes.length}) [prev=$prevNodeCount]; '
      'edges: ${current.edges.length} (+${addedEdges.length}, -${removedEdges.length}) [prev=$prevEdgeCount]',
    );

    if (addedNodes.isNotEmpty || removedNodes.isNotEmpty) {
      talker.debug(
        'Node change sets -> added: $addedNodes, removed: $removedNodes',
      );
    }
    if (addedEdges.isNotEmpty || removedEdges.isNotEmpty) {
      talker.debug(
        'Edge change sets -> added: $addedEdges, removed: $removedEdges',
      );
    }
  }

  static void logCleared({GraphData? previous}) {
    talker.warning(
      'Graph cleared. Previously ${previous?.nodes.length ?? 0} nodes and ${previous?.edges.length ?? 0} edges.',
    );
  }
}
