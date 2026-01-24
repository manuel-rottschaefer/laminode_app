import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ParamListItem extends ConsumerWidget {
  final CamParamEntry param;
  final bool isSelected;

  const ParamListItem({
    super.key,
    required this.param,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(schemaEditorProvider.notifier).selectParameter(param);
      },
      child: LamiBox(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        borderColor: isSelected ? Theme.of(context).colorScheme.primary : null,
        backgroundColor: isSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.1)
            : null,
        child: Row(
          children: [
            Icon(
              _getIconForType(param.quantity.quantityType),
              size: 16,
              color: param.isVisible
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    param.paramTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: param.isVisible
                          ? null
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                  Text(
                    param.paramName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: param.isVisible
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                param.isVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                size: 14,
              ),
              onPressed: () {
                ref
                    .read(schemaEditorProvider.notifier)
                    .toggleParameterVisibility(param.paramName);
              },
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
              splashRadius: 16,
              color: param.isVisible ? null : Theme.of(context).disabledColor,
            ),
          ],
        ),
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
