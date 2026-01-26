import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';

abstract class GraphSnapshotRepository {
  Future<void> saveSnapshot(GraphSnapshot snapshot);
  Future<GraphSnapshot?> loadSnapshot();
}
