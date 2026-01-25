import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/items/param_list_item.dart';

class ParamPanel extends ConsumerStatefulWidget {
  const ParamPanel({super.key});

  @override
  ConsumerState<ParamPanel> createState() => _ParamPanelState();
}

class _ParamPanelState extends ConsumerState<ParamPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(paramPanelProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        ref.read(paramPanelProvider.notifier).setSearchQuery('');
        FocusScope.of(context).unfocus(); // Clear focus when hiding
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paramPanelProvider);
    final items = ref.watch(paramPanelItemsProvider);

    // Sync search controller if state changes from elsewhere (e.g. navigation)
    if (_searchController.text != state.searchQuery) {
      _searchController.text = state.searchQuery;
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LamiPanelHeader(
          icon: Icons.tune_rounded,
          title: "Parameters",
          trailing: LamiToggleIcon(
            value: _isSearchVisible,
            icon: Icons.search_rounded,
            toggledIcon: Icons.search_off_rounded,
            onChanged: (val) => _toggleSearch(),
          ),
        ),

        // Search Box (Collapsible)
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: _isSearchVisible ? null : 0,
            child: Column(
              children: [
                LamiSearch(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: "Filter parameters...",
                ),
                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
        ),

        // Parameters List
        Expanded(
          child: LamiBox(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: items.isEmpty
                ? Center(
                    child: Text(
                      state.searchQuery.isEmpty
                          ? "No parameters available in schema."
                          : "No matches found.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: items.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ParamListItem(
                        key: ValueKey(item.param.paramName),
                        item: item,
                      );
                    },
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.m),
      ],
    );
  }
}
