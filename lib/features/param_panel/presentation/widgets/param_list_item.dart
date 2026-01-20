import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_info_box.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_config_box.dart';

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

class ParamListItemBody extends StatelessWidget {
  final ParamPanelItem item;

  const ParamListItemBody({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, AppSpacing.m),
      child: Column(
        children: [
          ParamInfoBox(
            param: item.param,
            description: item.param.paramDescription,
          ),
          const SizedBox(height: AppSpacing.s),
          const ParamConfigBox(),
        ],
      ),
    );
  }
}
