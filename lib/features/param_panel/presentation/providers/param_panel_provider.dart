import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_tab.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';

import 'param_panel_state.dart';
export 'param_panel_state.dart';
export 'param_panel_items_provider.dart';

class ParamPanelNotifier extends Notifier<ParamPanelState> {
  @override
  ParamPanelState build() {
    // Watch schema changes to reset state when schema changes
    ref.watch(schemaShopProvider.select((s) => s.activeSchema));

    final currentQuery = _getCurrentQuery();
    final selectedIndices = _getSelectedLayerIndices();
    final lockedParams = _getLockedParams();
    final selectedTabs = _getSelectedTabs();
    final branchedParamNames = _getBranchedParamNames();

    return ParamPanelState(
      searchQuery: currentQuery,
      expandedParamName: _getExpandedName(),
      history: _getHistory(),
      focusedParamName: _getFocusedName(),
      selectedLayerIndices: selectedIndices,
      lockedParams: lockedParams,
      selectedTabs: selectedTabs,
      branchedParamNames: branchedParamNames,
    );
  }

  Set<String> _getBranchedParamNames() {
    try {
      return state.branchedParamNames;
    } catch (_) {
      return const {};
    }
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

  void toggleBranching(String paramName) {
    final updatedBranched = Set<String>.from(state.branchedParamNames);
    if (updatedBranched.contains(paramName)) {
      updatedBranched.remove(paramName);
    } else {
      updatedBranched.add(paramName);
    }

    state = state.copyWith(branchedParamNames: updatedBranched);
  }

  void setBranchedParamNames(Set<String> names) {
    state = state.copyWith(branchedParamNames: names);
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

  void clearFocus() {
    state = state.copyWith(clearExpansion: true, clearFocus: true, history: []);
  }

  void updateFocusedParamValue(dynamic value) {
    if (state.focusedParamName != null) {
      updateParamValue(state.focusedParamName!, value);
    }
  }
}

final paramPanelProvider =
    NotifierProvider<ParamPanelNotifier, ParamPanelState>(() {
      return ParamPanelNotifier();
    });
