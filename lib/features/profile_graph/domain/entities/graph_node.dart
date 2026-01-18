import 'package:laminode_app/core/domain/entities/cam_param.dart';

abstract class GraphNode<T extends CamParameter> {
  final String nodeId;
  final T param;

  GraphNode({required this.nodeId, required this.param});
}
