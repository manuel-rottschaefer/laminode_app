import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';

class ParamValueInput extends ConsumerWidget {
  final ParamPanelItem item;
  final TextEditingController controller;

  const ParamValueInput({
    super.key,
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = item.param.isLocked;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !isLocked,
            onChanged: (value) {
              ref
                  .read(paramPanelProvider.notifier)
                  .updateParamValue(item.param.paramName, value);
            },
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isLocked
                  ? colorScheme.onSurface.withValues(alpha: 0.5)
                  : null,
            ),
            decoration: InputDecoration(
              isDense: true,
              suffixText: item.param.quantity.quantitySymbol,
              suffixStyle: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: AppSpacing.m,
              ),
              filled: true,
              fillColor: isLocked
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s),
        LamiIcon(
          icon: isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
          size: 18,
          padding: 8,
          onPressed: () {
            ref
                .read(paramPanelProvider.notifier)
                .toggleLock(item.param.paramName);
          },
          color: isLocked
              ? colorScheme.primary
              : colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        LamiIcon(
          icon: Icons.restart_alt_rounded,
          size: 18,
          padding: 8,
          onPressed: () {
            ref
                .read(paramPanelProvider.notifier)
                .resetParamValue(item.param.paramName);
          },
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}
