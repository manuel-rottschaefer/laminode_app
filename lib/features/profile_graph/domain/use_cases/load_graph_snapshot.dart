import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/repositories/graph_snapshot_repository.dart';

class LoadGraphSnapshot {
  final GraphSnapshotRepository repository;

  LoadGraphSnapshot(this.repository);

  Future<GraphSnapshot?> execute() {
    return repository.loadSnapshot();
  }
}
