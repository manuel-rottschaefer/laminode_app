import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/profile_graph/data/repositories/file_graph_snapshot_repository.dart';
import 'package:laminode_app/features/profile_graph/domain/repositories/graph_snapshot_repository.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/load_graph_snapshot.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/save_graph_snapshot.dart';

final graphSnapshotRepositoryProvider = Provider<GraphSnapshotRepository>((
  ref,
) {
  return FileGraphSnapshotRepository();
});

final loadGraphSnapshotUseCaseProvider = Provider<LoadGraphSnapshot>((ref) {
  return LoadGraphSnapshot(ref.watch(graphSnapshotRepositoryProvider));
});

final saveGraphSnapshotUseCaseProvider = Provider<SaveGraphSnapshot>((ref) {
  return SaveGraphSnapshot(ref.watch(graphSnapshotRepositoryProvider));
});
