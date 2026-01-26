import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_segmented_control.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_tab.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/tabs/hierarchy_tab.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/tabs/info_tab.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/tabs/layers_tab.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/tabs/value_tab.dart';

class ItemBody extends ConsumerWidget {
  final ParamPanelItem item;

  const ItemBody({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(
      paramPanelProvider.select(
        (s) => s.selectedTabs[item.param.paramName] ?? ParamTab.info,
      ),
    );

    final history = ref.watch(paramPanelProvider.select((s) => s.history));
    final hasHistory = history.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (hasHistory) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                onPressed: () => ref.read(paramPanelProvider.notifier).goBack(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                splashRadius: 18,
                tooltip: 'Back',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: AppSpacing.s),
            ],
            Expanded(
              child: LamiSegmentedControl<ParamTab>(
                selectedValue: activeTab,
                onSelected: (tab) => ref
                    .read(paramPanelProvider.notifier)
                    .setSelectedTab(item.param.paramName, tab),
                segments: const [
                  LamiSegment(
                    value: ParamTab.info,
                    icon: Icons.info_rounded,
                    tooltip: 'Info',
                  ),
                  LamiSegment(
                    value: ParamTab.edit,
                    icon: Icons.edit_rounded,
                    tooltip: 'Edit',
                  ),
                  LamiSegment(
                    value: ParamTab.stack,
                    icon: Icons.layers_rounded,
                    tooltip: 'Stack',
                  ),
                  LamiSegment(
                    value: ParamTab.hierarchy,
                    icon: Icons.hub_rounded,
                    tooltip: 'Hierarchy',
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        if (activeTab == ParamTab.info)
          InfoTab(param: item.param)
        else if (activeTab == ParamTab.edit)
          ValueTab(item: item)
        else if (activeTab == ParamTab.stack)
          LayersTab(param: item.param)
        else if (activeTab == ParamTab.hierarchy)
          HierarchyTab(param: item.param),
        const SizedBox(height: AppSpacing.m),
      ],
    );
  }
}
