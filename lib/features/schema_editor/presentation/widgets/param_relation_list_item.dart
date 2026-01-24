import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ParamRelationListItem extends StatelessWidget {
  final CamParamEntry parent;
  final CamParamEntry child;
  final VoidCallback onDelete;

  const ParamRelationListItem({
    super.key,
    required this.parent,
    required this.child,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LamiBox(
      padding: const EdgeInsets.all(AppSpacing.m),
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.2,
      ),
      child: Row(
        children: [
          Expanded(child: _buildParamInfo(context, parent)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
          ),
          Expanded(child: _buildParamInfo(context, child)),
          const SizedBox(width: AppSpacing.s),
          IconButton(
            icon: const Icon(LucideIcons.trash2, size: 18),
            onPressed: onDelete,
            color: theme.colorScheme.error.withValues(alpha: 0.7),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildParamInfo(BuildContext context, CamParamEntry p) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          p.paramTitle,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          p.paramName,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontSize: 10,
            fontFamily: 'monospace',
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
