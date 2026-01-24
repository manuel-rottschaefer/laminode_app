import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SchemaSelectionItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s),
      child: InkWell(
        onTap: onTap,
        child: LamiBox(
          borderColor: isSelected ? theme.colorScheme.primary : null,
          backgroundColor: isSelected
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
              : null,
          child: Row(
            children: [
              Icon(
                LucideIcons.binary,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Version: ${schema.version}",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                    Text(
                      "Released: ${schema.releaseDate}",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.pencil, size: 16),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                splashRadius: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              if (isSelected) ...[
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
    );
  }
}
