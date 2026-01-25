import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_tab.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';

final paramPanelItemsProvider = Provider<List<ParamPanelItem>>((ref) {
  final state = ref.watch(paramPanelProvider);
  final activeSchema = ref.watch(
    schemaShopProvider.select((s) => s.activeSchema),
  );
  final layers = ref.watch(layerPanelProvider.select((s) => s.layers));

  if (activeSchema == null) return const [];

  final normalizedQuery = state.searchQuery.toLowerCase();
  final List<ParamPanelItem> filteredItems = [];

  for (final paramDef in activeSchema.availableParameters) {
    final matchesSearch =
        normalizedQuery.isNotEmpty &&
        (paramDef.paramName.toLowerCase().contains(normalizedQuery) ||
            paramDef.paramTitle.toLowerCase().contains(normalizedQuery));

    if (normalizedQuery.isNotEmpty &&
        !matchesSearch &&
        state.focusedParamName == null) {
      continue;
    }

    if (state.focusedParamName != null &&
        paramDef.paramName != state.focusedParamName) {
      continue;
    }

    // Merge layer value
    CamParamEntry param = paramDef;
    final selectedIndex = state.selectedLayerIndices[paramDef.paramName];

    if (selectedIndex != null &&
        selectedIndex >= 0 &&
        selectedIndex < layers.length) {
      final layer = layers[selectedIndex];
      try {
        final layerParam = layer.parameters?.firstWhere(
          (p) => p.paramName == paramDef.paramName,
        );
        if (layerParam != null) {
          param = layerParam;
        }
      } catch (_) {
        // Param not edited in this layer yet, use schema def as base
      }
    }

    // Apply lock from state
    if (state.lockedParams[param.paramName] ?? false) {
      param = param.copyWith(isLocked: true);
    }

    final itemState = state.focusedParamName != null
        ? ParamItemState.reference
        : (normalizedQuery.isNotEmpty
              ? ParamItemState.search
              : ParamItemState.schema);

    filteredItems.add(ParamPanelItem(param: param, state: itemState));
  }
  return filteredItems;
});

class ParamPanelState {
  final String searchQuery;
  final String? expandedParamName;
  final List<String> history;
  final String? focusedParamName;
  final Map<String, int> selectedLayerIndices;
  final Map<String, bool> lockedParams;
  final Map<String, ParamTab> selectedTabs;

  ParamPanelState({
    this.searchQuery = '',
    this.expandedParamName,
    this.history = const [],
    this.focusedParamName,
    this.selectedLayerIndices = const {},
    this.lockedParams = const {},
    this.selectedTabs = const {},
  });

  ParamPanelState copyWith({
    String? searchQuery,
    String? expandedParamName,
    List<String>? history,
    String? focusedParamName,
    Map<String, int>? selectedLayerIndices,
    Map<String, bool>? lockedParams,
    Map<String, ParamTab>? selectedTabs,
    bool clearExpansion = false,
    bool clearFocus = false,
  }) {
    return ParamPanelState(
      searchQuery: searchQuery ?? this.searchQuery,
      expandedParamName: clearExpansion
          ? null
          : (expandedParamName ?? this.expandedParamName),
      history: history ?? this.history,
      focusedParamName: clearFocus
          ? null
          : (focusedParamName ?? this.focusedParamName),
      selectedLayerIndices: selectedLayerIndices ?? this.selectedLayerIndices,
      lockedParams: lockedParams ?? this.lockedParams,
      selectedTabs: selectedTabs ?? this.selectedTabs,
    );
  }
}

class ParamPanelNotifier extends Notifier<ParamPanelState> {
  @override
  ParamPanelState build() {
    // Watch schema changes to reset state when schema changes
    ref.watch(schemaShopProvider.select((s) => s.activeSchema));

    final currentQuery = _getCurrentQuery();
    final selectedIndices = _getSelectedLayerIndices();
    final lockedParams = _getLockedParams();
    final selectedTabs = _getSelectedTabs();

    return ParamPanelState(
      searchQuery: currentQuery,
      expandedParamName: _getExpandedName(),
      history: _getHistory(),
      focusedParamName: _getFocusedName(),
      selectedLayerIndices: selectedIndices,
      lockedParams: lockedParams,
      selectedTabs: selectedTabs,
    );
  }

  Map<String, ParamTab> _getSelectedTabs() {
    try {
      return state.selectedTabs;
    } catch (_) {
      return const {};
    }
  }

  Map<String, bool> _getLockedParams() {
    try {
      return state.lockedParams;
    } catch (_) {
      return const {};
    }
  }

  Map<String, int> _getSelectedLayerIndices() {
    try {
      return state.selectedLayerIndices;
    } catch (_) {
      return const {};
    }
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

  List<String> _getHistory() {
    try {
      return state.history;
    } catch (_) {
      return const [];
    }
  }

  String? _getFocusedName() {
    try {
      return state.focusedParamName;
    } catch (_) {
      return null;
    }
  }

  void setSearchQuery(String query) {
    if (state.searchQuery != query) {
      state = state.copyWith(
        searchQuery: query,
        clearExpansion: true,
        clearFocus: true,
        history: [], // Clear history when searching manually
      );
    }
  }

  void navigateToParam(String paramName) {
    // Push current expanded param to history if it's different
    final currentHistory = List<String>.from(state.history);
    if (state.expandedParamName != null &&
        state.expandedParamName != paramName) {
      currentHistory.add(state.expandedParamName!);
    }

    state = state.copyWith(
      searchQuery: '',
      expandedParamName: paramName,
      history: currentHistory,
      focusedParamName: paramName,
    );
  }

  void goBack() {
    if (state.history.isEmpty) return;

    final newHistory = List<String>.from(state.history);
    final previousParamName = newHistory.removeLast();

    final String? newFocusName = newHistory.isEmpty ? null : previousParamName;

    state = state.copyWith(
      searchQuery: '',
      expandedParamName: previousParamName,
      history: newHistory,
      focusedParamName: newFocusName,
      clearFocus: newFocusName == null,
    );
  }

  void toggleExpansion(String paramName) {
    if (state.expandedParamName == paramName) {
      state = state.copyWith(clearExpansion: true);
    } else {
      state = state.copyWith(expandedParamName: paramName);
    }
  }

  void setSelectedLayerIndex(String paramName, int layerIndex) {
    final updatedIndices = Map<String, int>.from(state.selectedLayerIndices);
    updatedIndices[paramName] = layerIndex;

    state = state.copyWith(selectedLayerIndices: updatedIndices);
  }

  void setSelectedTab(String paramName, ParamTab tab) {
    final updatedTabs = Map<String, ParamTab>.from(state.selectedTabs);
    updatedTabs[paramName] = tab;

    state = state.copyWith(selectedTabs: updatedTabs);
  }

  void toggleLock(String paramName) {
    final updatedLocked = Map<String, bool>.from(state.lockedParams);
    final currentlyLocked = updatedLocked[paramName] ?? false;
    updatedLocked[paramName] = !currentlyLocked;

    state = state.copyWith(lockedParams: updatedLocked);
  }

  void updateParamValue(String paramName, dynamic value) {
    final selectedIndex = state.selectedLayerIndices[paramName];
    if (selectedIndex != null) {
      if (state.lockedParams[paramName] ?? false) return;

      final activeSchema = ref.read(schemaShopProvider).activeSchema;
      final paramDef = activeSchema?.availableParameters.firstWhere(
        (p) => p.paramName == paramName,
      );

      if (paramDef == null) return;

      dynamic finalValue = value;
      if (paramDef.quantity.quantityType == QuantityType.numeric &&
          value is String) {
        finalValue = double.tryParse(value) ?? paramDef.value;
      }

      ref
          .read(layerPanelProvider.notifier)
          .updateParamValue(selectedIndex, paramName, finalValue);
    }
  }

  void resetParamValue(String paramName) {
    final selectedIndex = state.selectedLayerIndices[paramName];
    if (selectedIndex != null) {
      if (state.lockedParams[paramName] ?? false) return;

      ref
          .read(layerPanelProvider.notifier)
          .resetParamValue(selectedIndex, paramName);
    }
  }
}

final paramPanelProvider =
    NotifierProvider<ParamPanelNotifier, ParamPanelState>(() {
      return ParamPanelNotifier();
    });
