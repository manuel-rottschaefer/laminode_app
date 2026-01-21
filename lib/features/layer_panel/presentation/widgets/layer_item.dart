import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/edit_layer_dialog.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expandedIndex = ref.watch(
      layerPanelProvider.select((s) => s.expandedIndex),
    );
    final isExpanded = expandedIndex == widget.index;

    final categories = ref.watch(activeSchemaCategoriesProvider);
    final category = categories.cast<CamCategoryEntry?>().firstWhere(
      (c) => c?.categoryName == widget.entry.layerCategory,
      orElse: () => null,
    );
    final categoryColor = category != null
        ? LamiColors.registry[category.categoryColorName]
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: LamiBox(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => ref
                    .read(layerPanelProvider.notifier)
                    .setExpandedIndex(widget.index),
                onHover: (hovering) => setState(() => isHovered = hovering),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      // Status / Drag Hint
                      ReorderableDragStartListener(
                        index: widget.index,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: (isHovered || isExpanded) ? 28 : 0,
                          curve: Curves.easeInOut,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 160),
                            opacity: (isHovered || isExpanded) ? 1 : 0,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.drag_handle_rounded,
                                size: (isHovered || isExpanded) ? 20 : 18,
                                color: colorScheme.onSurface.withValues(
                                  alpha: (isHovered || isExpanded) ? 0.4 : 0.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Header Content
                      Expanded(
                        child: AnimatedPadding(
                          duration: const Duration(milliseconds: 180),
                          padding: EdgeInsets.only(
                            left: (isHovered || isExpanded)
                                ? AppSpacing.l
                                : AppSpacing.m,
                          ),
                          curve: Curves.easeInOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.entry.layerName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.entry.isActive
                                      ? colorScheme.onSurface
                                      : theme.disabledColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${widget.entry.parameters?.length ?? 0} effective parameters",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Toggle Active
                      Transform.scale(
                        scale: 0.85,
                        child: Checkbox(
                          value: widget.entry.isActive,
                          onChanged: (val) {
                            if (val != null) {
                              ref
                                  .read(layerPanelProvider.notifier)
                                  .toggleLayerActive(widget.index);
                            }
                          },
                          activeColor: categoryColor ?? colorScheme.primary,
                          checkColor: categoryColor != null
                              ? Colors.white
                              : colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),

                      // Expand Icon
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: (isHovered || isExpanded) ? 24 : 0,
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: (isHovered || isExpanded) ? 1 : 0,
                          child: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: colorScheme.onSurface,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isExpanded) ...[
                const SizedBox(height: AppSpacing.s),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: AppSpacing.m,
                    bottom: AppSpacing.s,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          LamiIconButton(
                            icon: widget.entry.isLocked
                                ? Icons.lock_rounded
                                : Icons.lock_open_rounded,
                            onPressed: () {
                              ref
                                  .read(layerPanelProvider.notifier)
                                  .toggleLayerLocked(widget.index);
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
                                  content: EditLayerDialog(
                                    entry: widget.entry,
                                    index: widget.index,
                                  ),
                                ),
                              );
                            },
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.m),
                          LamiIconButton(
                            icon: Icons.delete_outline_rounded,
                            onPressed: () {
                              ref
                                  .read(layerPanelProvider.notifier)
                                  .removeLayer(widget.index);
                            },
                            color: colorScheme.error,
                            size: 16,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          LamiIconButton(
                            icon: Icons.arrow_upward_rounded,
                            onPressed: () {
                              ref
                                  .read(layerPanelProvider.notifier)
                                  .moveLayerUp(widget.index);
                            },
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          LamiIconButton(
                            icon: Icons.arrow_downward_rounded,
                            onPressed: () {
                              ref
                                  .read(layerPanelProvider.notifier)
                                  .moveLayerDown(widget.index);
                            },
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
