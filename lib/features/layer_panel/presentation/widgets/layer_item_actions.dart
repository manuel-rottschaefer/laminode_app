import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_colored_badge.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/edit_layer_dialog.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';

class LayerItemActions extends ConsumerWidget {
  final LamiLayerEntry entry;
  final int index;
  final bool canMoveUp;
  final bool canMoveDown;
  final CamCategoryEntry? category;

  const LayerItemActions({
    super.key,
    required this.entry,
    required this.index,
    required this.canMoveUp,
    required this.canMoveDown,
    this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = category != null
        ? LamiColor.fromString(category!.categoryColorName).value
        : null;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: AppSpacing.s, bottom: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (canMoveUp) ...[
                LamiIconButton(
                  icon: Icons.arrow_upward_rounded,
                  onPressed: () {
                    ref.read(layerPanelProvider.notifier).moveLayerUp(index);
                  },
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.s),
              ],
              if (canMoveDown) ...[
                LamiIconButton(
                  icon: Icons.arrow_downward_rounded,
                  onPressed: () {
                    ref.read(layerPanelProvider.notifier).moveLayerDown(index);
                  },
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.s),
              ],
              if (canMoveUp || canMoveDown) const SizedBox(width: AppSpacing.s),
              LamiIconButton(
                icon: entry.isLocked
                    ? Icons.lock_rounded
                    : Icons.lock_open_rounded,
                onPressed: () {
                  ref
                      .read(layerPanelProvider.notifier)
                      .toggleLayerLocked(index);
                },
                size: 16,
              ),
              const SizedBox(width: AppSpacing.m),
              LamiIconButton(
                icon: Icons.edit_rounded,
                onPressed: () {
                  showLamiDialog(
                    context: context,
                    model: LamiDialogModel(
                      title: "Edit Layer",
                      content: EditLayerDialog(entry: entry, index: index),
                    ),
                  );
                },
                size: 16,
              ),
              const SizedBox(width: AppSpacing.m),
              LamiIconButton(
                icon: Icons.delete_outline_rounded,
                onPressed: () {
                  ref.read(layerPanelProvider.notifier).removeLayer(index);
                },
                color: colorScheme.error,
                size: 16,
              ),
            ],
          ),
          if (category != null)
            LamiColoredBadge(
              label: category!.categoryName,
              color: categoryColor ?? colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
