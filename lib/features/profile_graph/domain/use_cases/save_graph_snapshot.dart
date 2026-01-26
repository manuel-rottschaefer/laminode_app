import 'package:laminode_app/features/profile_graph/domain/entities/graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/repositories/graph_snapshot_repository.dart';

class SaveGraphSnapshot {
  final GraphSnapshotRepository repository;

  SaveGraphSnapshot(this.repository);

  Future<void> execute(GraphSnapshot snapshot) {
    return repository.saveSnapshot(snapshot);
  }
}
