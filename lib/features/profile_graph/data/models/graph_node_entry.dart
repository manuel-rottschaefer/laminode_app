import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';

class GraphNodeEntry extends GraphNode<CamParamEntry> {
  GraphNodeEntry({required super.nodeId, required super.param});
}
