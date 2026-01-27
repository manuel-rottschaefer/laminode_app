import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_item_header.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_item_actions.dart';

class LayerItem extends ConsumerStatefulWidget {
  final LamiLayerEntry entry;
  final int index;

  const LayerItem({super.key, required this.entry, required this.index});

  @override
  ConsumerState<LayerItem> createState() => _LayerItemState();
}

class _LayerItemState extends ConsumerState<LayerItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final expandedIndex = ref.watch(
      layerPanelProvider.select((s) => s.expandedIndex),
    );
    final layersCount = ref.watch(
      layerPanelProvider.select((s) => s.layers.length),
    );
    final isExpanded = expandedIndex == widget.index;

    final categories = ref.watch(activeSchemaCategoriesProvider);
    final category = categories.cast<CamCategoryEntry?>().firstWhere(
      (c) => c?.categoryName == widget.entry.layerCategory,
      orElse: () => null,
    );

    final canMoveUp = widget.index > 0;
    final canMoveDown = widget.index < layersCount - 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: LamiBox(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayerItemHeader(
                entry: widget.entry,
                index: widget.index,
                isHovered: isHovered,
                isExpanded: isExpanded,
                category: category,
                onTap: () => ref
                    .read(layerPanelProvider.notifier)
                    .setExpandedIndex(widget.index),
                onHover: (hovering) => setState(() => isHovered = hovering),
                onToggleActive: (val) {
                  if (val != null) {
                    ref
                        .read(layerPanelProvider.notifier)
                        .toggleLayerActive(widget.index);
                  }
                },
              ),
              if (isExpanded) ...[
                const SizedBox(height: AppSpacing.xs),
                LayerItemActions(
                  entry: widget.entry,
                  index: widget.index,
                  canMoveUp: canMoveUp,
                  canMoveDown: canMoveDown,
                  category: category,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
