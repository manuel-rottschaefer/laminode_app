import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SchemaSelectionItem extends StatefulWidget {
  final SchemaRef schema;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const SchemaSelectionItem({
    super.key,
    required this.schema,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
  });

  @override
  State<SchemaSelectionItem> createState() => _SchemaSelectionItemState();
}

class _SchemaSelectionItemState extends State<SchemaSelectionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: LamiBox(
            borderColor: widget.isSelected ? theme.colorScheme.primary : null,
            backgroundColor: widget.isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
                : null,
            child: Row(
              children: [
                Icon(
                  LucideIcons.binary,
                  size: 20,
                  color: widget.isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Version: ${widget.schema.version}",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: widget.isSelected
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                      Text(
                        "Released: ${widget.schema.releaseDate}",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _isHovered ? 40 : 0,
                  curve: Curves.easeInOut,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 200),
                        offset: _isHovered ? Offset.zero : const Offset(0.5, 0),
                        child: IconButton(
                          icon: const Icon(LucideIcons.pencil, size: 16),
                          onPressed: widget.onEdit,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.isSelected) ...[
                  const SizedBox(width: AppSpacing.s),
                  Icon(
                    LucideIcons.check,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
