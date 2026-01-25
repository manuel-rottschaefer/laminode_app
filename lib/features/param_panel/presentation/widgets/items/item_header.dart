import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_colored_badge.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';

class ItemHeader extends StatefulWidget {
  final ParamPanelItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  const ItemHeader({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<ItemHeader> createState() => _ItemHeaderState();
}

class _ItemHeaderState extends State<ItemHeader> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSearchState = widget.item.state == ParamItemState.search;
    final bool isReferenceState = widget.item.state == ParamItemState.reference;

    final categoryColor = LamiColor.fromString(
      widget.item.param.category.categoryColorName,
    ).value;

    final TextStyle titleStyle = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: (isSearchState || isReferenceState || widget.isExpanded)
          ? FontWeight.bold
          : FontWeight.normal,
      fontSize: widget.isExpanded ? 12.5 : 11.5,
      letterSpacing: 0.3,
      color: (widget.isExpanded || isSearchState || isReferenceState || _isHovered)
          ? colorScheme.onSurface.withValues(alpha: 0.8)
          : colorScheme.onSurface.withValues(alpha: 0.5),
    );

    IconData icon = Icons.schema_rounded;
    if (isSearchState) icon = Icons.visibility_rounded;
    if (isReferenceState) icon = Icons.link_rounded;

    final Color iconColor = widget.isExpanded
        ? colorScheme.onSurface.withValues(alpha: 0.7)
        : categoryColor.withValues(alpha: 0.8);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: categoryColor.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 14.0,
            bottom: 2.0,
            left: 8.0,
            right: 8.0,
          ),
          child: Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: titleStyle,
                        child: Text(
                          widget.item.param.paramTitle,
                          maxLines: widget.isExpanded ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (widget.isExpanded)
                      LamiColoredBadge(
                        color: categoryColor,
                        label: widget.item.param.category.categoryTitle
                            .toUpperCase(),
                      )
                    else if (widget.item.param.isEdited)
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s,
                          ),
                          child: Text(
                            widget.item.param.value.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: categoryColor,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Icon(
                widget.isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
