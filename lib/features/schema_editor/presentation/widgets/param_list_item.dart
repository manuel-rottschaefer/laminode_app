import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ParamListItem extends ConsumerStatefulWidget {
  final CamParamEntry param;
  final bool isSelected;

  const ParamListItem({
    super.key,
    required this.param,
    required this.isSelected,
  });

  @override
  ConsumerState<ParamListItem> createState() => _ParamListItemState();
}

class _ParamListItemState extends ConsumerState<ParamListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final param = widget.param;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          InkWell(
            onTap: () {
              ref.read(schemaEditorProvider.notifier).selectParameter(param);
            },
            child: LamiBox(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
                vertical: AppSpacing.s,
              ),
              borderColor: widget.isSelected ? theme.colorScheme.primary : null,
              backgroundColor: widget.isSelected
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
                  : null,
              child: Row(
                children: [
                  Icon(
                    _getIconForType(param.quantity.quantityType),
                    size: 16,
                    color: LamiColor.fromString(
                      param.category.categoryColorName,
                    ).value,
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          param.paramTitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: param.isVisible ? null : theme.disabledColor,
                          ),
                        ),
                        Text(
                          param.paramName,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: param.isVisible
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            right: _isHovered ? 8 : -32,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(LucideIcons.pencil, size: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(QuantityType type) {
    switch (type) {
      case QuantityType.numeric:
        return LucideIcons.hash;
      case QuantityType.boolean:
        return LucideIcons.toggleLeft;
      case QuantityType.choice:
        return LucideIcons.list;
    }
  }
}
