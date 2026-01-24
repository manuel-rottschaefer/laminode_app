import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_list_item_header.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_list_item_body.dart';

class ParamListItem extends ConsumerWidget {
  final ParamPanelItem item;
  final bool showDivider;

  const ParamListItem({super.key, required this.item, this.showDivider = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expandedName = ref.watch(
      paramPanelProvider.select((s) => s.expandedParamName),
    );
    final isExpanded = expandedName == item.param.paramName;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ParamListItemHeader(
          item: item,
          isExpanded: isExpanded,
          onTap: () => ref
              .read(paramPanelProvider.notifier)
              .toggleExpansion(item.param.paramName),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: ParamListItemBody(item: item),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
          sizeCurve: Curves.easeInOutCubic,
        ),
        if (showDivider && !isExpanded)
          Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}
