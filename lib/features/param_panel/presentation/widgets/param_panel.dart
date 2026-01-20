import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_list_item.dart';

class ParamPanel extends ConsumerStatefulWidget {
  const ParamPanel({super.key});

  @override
  ConsumerState<ParamPanel> createState() => _ParamPanelState();
}

class _ParamPanelState extends ConsumerState<ParamPanel> {
  final TextEditingController _searchController = TextEditingController();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paramPanelProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LamiPanelHeader(icon: Icons.tune_rounded, title: "Parameters"),
        const SizedBox(height: AppSpacing.s),

        // Search Box (Always visible/pressed)
        LamiSearch(
          controller: _searchController,
          hintText: "Filter parameters...",
        ),
        const SizedBox(height: AppSpacing.m),

        // Parameters List
        Expanded(
          child: LamiBox(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: state.items.isEmpty
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
                    itemCount: state.items.length,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return ParamListItem(
                        item: state.items[index],
                        showDivider: index < state.items.length - 1,
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
