import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';

class HierarchyTab extends ConsumerWidget {
  final CamParamEntry param;

  const HierarchyTab({super.key, required this.param});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = LamiColor.fromString(
      param.category.categoryColorName,
    ).value;

    return LamiBox(
      backgroundColor: colorScheme.surface,
      borderColor: categoryColor.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.s),
            child: Text(
              "PARAMETER HIERARCHY",
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          _buildTreeItem(context, ref, param, isRoot: true),
        ],
      ),
    );
  }

  Widget _buildTreeItem(
    BuildContext context,
    WidgetRef ref,
    CamParamEntry currentParam, {
    bool isRoot = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = LamiColor.fromString(
      currentParam.category.categoryColorName,
    ).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: isRoot
              ? null
              : () => ref
                    .read(paramPanelProvider.notifier)
                    .navigateToParam(currentParam.paramName),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  isRoot
                      ? Icons.account_tree_rounded
                      : Icons.subdirectory_arrow_right_rounded,
                  size: 14,
                  color: isRoot
                      ? categoryColor
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    currentParam.paramTitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
                      color: isRoot
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (!isRoot)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ),
        ),
        if (currentParam.children.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: currentParam.children.map((child) {
                // This is a placeholder as full recursive tree resolution
                // would require fetching child definitions from schema
                return _buildPlaceholderChild(context, child.childParamName);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholderChild(BuildContext context, String name) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Row(
        children: [
          Icon(
            Icons.subdirectory_arrow_right_rounded,
            size: 12,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            name,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
