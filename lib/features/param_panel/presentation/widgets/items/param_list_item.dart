import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/items/item_body.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/items/item_header.dart';

class ParamListItem extends ConsumerWidget {
  final ParamPanelItem item;

  const ParamListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isExpanded = ref.watch(
      paramPanelProvider.select(
        (s) => s.expandedParamName == item.param.paramName,
      ),
    );

    // Auto-scroll when expanded
    ref.listen(
      paramPanelProvider.select(
        (s) => s.expandedParamName == item.param.paramName,
      ),
      (prev, next) {
        if (next == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              alignment: 0.1,
              curve: Curves.easeInOut,
            );
          });
        }
      },
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ItemHeader(
          item: item,
          isExpanded: isExpanded,
          onTap: () => ref
              .read(paramPanelProvider.notifier)
              .toggleExpansion(item.param.paramName),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
              bottom: AppSpacing.m,
            ),
            child: ItemBody(item: item),
          ),
      ],
    );
  }
}
