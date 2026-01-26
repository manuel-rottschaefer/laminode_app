import 'package:laminode_app/features/param_panel/domain/entities/param_tab.dart';

class ParamPanelState {
  final String searchQuery;
  final String? expandedParamName;
  final List<String> history;
  final String? focusedParamName;
  final Map<String, int> selectedLayerIndices;
  final Map<String, bool> lockedParams;
  final Map<String, ParamTab> selectedTabs;
  final Set<String> branchedParamNames;

  ParamPanelState({
    this.searchQuery = '',
    this.expandedParamName,
    this.history = const [],
    this.focusedParamName,
    this.selectedLayerIndices = const {},
    this.lockedParams = const {},
    this.selectedTabs = const {},
    this.branchedParamNames = const {},
  });

  ParamPanelState copyWith({
    String? searchQuery,
    String? expandedParamName,
    List<String>? history,
    String? focusedParamName,
    Map<String, int>? selectedLayerIndices,
    Map<String, bool>? lockedParams,
    Map<String, ParamTab>? selectedTabs,
    Set<String>? branchedParamNames,
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
      branchedParamNames: branchedParamNames ?? this.branchedParamNames,
    );
  }
}
