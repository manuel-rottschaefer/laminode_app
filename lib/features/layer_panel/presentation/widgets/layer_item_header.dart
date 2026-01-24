import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';

class LayerItemHeader extends StatelessWidget {
  final LamiLayerEntry entry;
  final int index;
  final bool isHovered;
  final bool isExpanded;
  final Color? categoryColor;
  final VoidCallback onTap;
  final Function(bool) onHover;
  final Function(bool?) onToggleActive;

  const LayerItemHeader({
    super.key,
    required this.entry,
    required this.index,
    required this.isHovered,
    required this.isExpanded,
    this.categoryColor,
    required this.onTap,
    required this.onHover,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      onHover: onHover,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            // Status / Drag Hint
            ReorderableDragStartListener(
              index: index,
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
                  left: (isHovered || isExpanded) ? AppSpacing.l : AppSpacing.m,
                ),
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      entry.layerName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: entry.isActive
                            ? colorScheme.onSurface
                            : theme.disabledColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${entry.parameters?.length ?? 0} effective parameters",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
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
                value: entry.isActive,
                onChanged: onToggleActive,
                activeColor: categoryColor ?? colorScheme.primary,
                checkColor: categoryColor != null
                    ? Colors.white
                    : colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    );
  }
}
