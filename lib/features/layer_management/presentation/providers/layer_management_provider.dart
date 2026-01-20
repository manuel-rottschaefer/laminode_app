import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/layer_management/data/datasources/layer_local_data_source.dart';
import 'package:laminode_app/features/layer_management/data/repositories/layer_management_repository_impl.dart';
import 'package:laminode_app/features/layer_management/domain/repositories/layer_management_repository.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

final layerLocalDataSourceProvider = Provider<LayerLocalDataSource>((ref) {
  return LayerLocalDataSourceImpl();
});

final layerManagementRepositoryProvider = Provider<LayerManagementRepository>((
  ref,
) {
  return LayerManagementRepositoryImpl(ref.watch(layerLocalDataSourceProvider));
});

final storedLayersProvider = FutureProvider<List<LamiLayerEntry>>((ref) async {
  final repository = ref.watch(layerManagementRepositoryProvider);
  return await repository.getStoredLayers();
});

class LayerManagementState {
  final String searchQuery;
  final bool isImporting;

  LayerManagementState({this.searchQuery = '', this.isImporting = false});

  LayerManagementState copyWith({String? searchQuery, bool? isImporting}) {
    return LayerManagementState(
      searchQuery: searchQuery ?? this.searchQuery,
      isImporting: isImporting ?? this.isImporting,
    );
  }
}

class LayerManagementNotifier
    extends AutoDisposeNotifier<LayerManagementState> {
  @override
  LayerManagementState build() {
    return LayerManagementState();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> importLayer(String filePath) async {
    state = state.copyWith(isImporting: true);
    try {
      await ref.read(layerManagementRepositoryProvider).importLayer(filePath);
      ref.invalidate(storedLayersProvider);
    } finally {
      state = state.copyWith(isImporting: false);
    }
  }
}

final layerManagementProvider =
    AutoDisposeNotifierProvider<LayerManagementNotifier, LayerManagementState>(
      () => LayerManagementNotifier(),
    );
