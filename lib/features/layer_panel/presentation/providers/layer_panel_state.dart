import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

class LayerPanelState {
  final List<LamiLayerEntry> layers;
  final int? expandedIndex;
  final String searchQuery;

  LayerPanelState({
    this.layers = const [],
    this.expandedIndex,
    this.searchQuery = '',
  });

  LayerPanelState copyWith({
    List<LamiLayerEntry>? layers,
    int? expandedIndex,
    bool clearExpanded = false,
    String? searchQuery,
  }) {
    return LayerPanelState(
      layers: layers ?? this.layers,
      expandedIndex: clearExpanded
          ? null
          : (expandedIndex ?? this.expandedIndex),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
