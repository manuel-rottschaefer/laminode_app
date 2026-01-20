import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';

class ParamPanelState {
  final String searchQuery;
  final List<ParamPanelItem> items;
  final String? expandedParamName;

  ParamPanelState({
    this.searchQuery = '',
    this.items = const [],
    this.expandedParamName,
  });

  ParamPanelState copyWith({
    String? searchQuery,
    List<ParamPanelItem>? items,
    String? expandedParamName,
    bool clearExpansion = false,
  }) {
    return ParamPanelState(
      searchQuery: searchQuery ?? this.searchQuery,
      items: items ?? this.items,
      expandedParamName: clearExpansion
          ? null
          : (expandedParamName ?? this.expandedParamName),
    );
  }
}

class ParamPanelNotifier extends Notifier<ParamPanelState> {
  @override
  ParamPanelState build() {
    // Watch schema changes to refresh items automatically
    final activeSchema = ref.watch(
      schemaShopProvider.select((s) => s.activeSchema),
    );

    // We want to preserve the search query if it was already set
    // In Notifier, build() can be called multiple times.
    // However, if we want to keep the search query, we should probably
    // access the previous state if possible, but build() is supposed to be pureish.

    // Actually, in Riverpod Notifiers, if you want to persist some state across
    // rebuilds triggered by build(), you might have a problem if build() returns a new state.

    // BUT! Riverpod Notifier build() is called when dependencies change.
    // If we want to keep the searchQuery, we can just use the current state's searchQuery
    // if state is initialized.

    final currentQuery = _getCurrentQuery();

    final List<ParamPanelItem> filteredItems = _getFilteredItems(
      activeSchema,
      currentQuery,
    );

    return ParamPanelState(
      searchQuery: currentQuery,
      items: filteredItems,
      expandedParamName: _getExpandedName(),
    );
  }

  String _getCurrentQuery() {
    try {
      return state.searchQuery;
    } catch (_) {
      return '';
    }
  }

  String? _getExpandedName() {
    try {
      return state.expandedParamName;
    } catch (_) {
      return null;
    }
  }

  void setSearchQuery(String query) {
    if (state.searchQuery != query) {
      final activeSchema = ref.read(schemaShopProvider).activeSchema;
      state = state.copyWith(
        searchQuery: query,
        items: _getFilteredItems(activeSchema, query),
        clearExpansion: true,
      );
    }
  }

  void toggleExpansion(String paramName) {
    if (state.expandedParamName == paramName) {
      state = state.copyWith(clearExpansion: true);
    } else {
      state = state.copyWith(expandedParamName: paramName);
    }
  }

  List<ParamPanelItem> _getFilteredItems(
    CamSchemaEntry? activeSchema,
    String query,
  ) {
    if (activeSchema == null) return const [];

    final normalizedQuery = query.toLowerCase();
    final List<ParamPanelItem> filteredItems = [];

    for (final param in activeSchema.availableParameters) {
      final matchesSearch =
          normalizedQuery.isNotEmpty &&
          param.paramTitle.toLowerCase().contains(normalizedQuery);

      if (matchesSearch) {
        filteredItems.add(
          ParamPanelItem(param: param, state: ParamItemState.search),
        );
      } else if (normalizedQuery.isEmpty) {
        filteredItems.add(
          ParamPanelItem(param: param, state: ParamItemState.schema),
        );
      }
    }
    return filteredItems;
  }
}

final paramPanelProvider =
    NotifierProvider<ParamPanelNotifier, ParamPanelState>(() {
      return ParamPanelNotifier();
    });
