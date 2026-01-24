import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';

class ParamListItemHeader extends StatefulWidget {
  final ParamPanelItem item;
  final bool isExpanded;
  final VoidCallback onTap;

  const ParamListItemHeader({
    super.key,
    required this.item,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<ParamListItemHeader> createState() => _ParamListItemHeaderState();
}

class _ParamListItemHeaderState extends State<ParamListItemHeader> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isSearchState = widget.item.state == ParamItemState.search;

    final TextStyle titleStyle = theme.textTheme.bodyMedium!.copyWith(
      fontWeight: (isSearchState || widget.isExpanded)
          ? FontWeight.bold
          : FontWeight.normal,
      fontSize: widget.isExpanded ? 13 : 12,
      color: (isSearchState || widget.isExpanded || _isHovered)
          ? colorScheme.onSurface
          : colorScheme.onSurface.withValues(alpha: 0.6),
    );

    final IconData icon = isSearchState
        ? Icons.visibility_rounded
        : Icons.schema_rounded;

    final Color iconColor = (isSearchState || widget.isExpanded)
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.3);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: colorScheme.primary.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.m,
            horizontal: 4.0,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.isExpanded
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: titleStyle,
                  child: Text(
                    widget.item.param.paramTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (widget.item.param.isEdited && !widget.isExpanded)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s,
                    ),
                    child: Text(
                      "${widget.item.param.value}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              RotationTransition(
                turns: AlwaysStoppedAnimation(widget.isExpanded ? 0.5 : 0),
                child: Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
