import 'graph_node.dart';
import 'graph_edge.dart';

class GraphData {
  final Map<String, GraphNode> nodes;
  final Set<GraphEdge> edges;

  const GraphData({required this.nodes, required this.edges});

  const GraphData.empty() : nodes = const {}, edges = const {};

  bool get isEmpty => nodes.isEmpty;
}
