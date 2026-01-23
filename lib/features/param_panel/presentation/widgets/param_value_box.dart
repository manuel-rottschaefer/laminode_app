import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';

class ParamValueBox extends ConsumerStatefulWidget {
  final ParamPanelItem item;

  const ParamValueBox({super.key, required this.item});

  @override
  ConsumerState<ParamValueBox> createState() => _ParamValueBoxState();
}

class _ParamValueBoxState extends ConsumerState<ParamValueBox> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialValue = (widget.item.param.value ?? widget.item.param.evalSuggest()).toString();
    _controller = TextEditingController(text: initialValue);
  }

  @override
  void didUpdateWidget(ParamValueBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue = (widget.item.param.value ?? widget.item.param.evalSuggest()).toString();
    if (newValue != _controller.text) {
      _controller.text = newValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = widget.item.param.isLocked;
    final item = widget.item;

    return LamiBox(
      backgroundColor: colorScheme.surface,
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "CURRENT VALUE",
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !isLocked,
                  onChanged: (value) {
                    ref.read(paramPanelProvider.notifier).updateParamValue(item.param.paramName, value);
                  },
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isLocked ? colorScheme.onSurface.withValues(alpha: 0.5) : null,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: item.param.quantity.quantitySymbol,
                    suffixStyle: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 0.7),
                      fontWeight: FontWeight.bold,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppSpacing.m),
                    filled: true,
                    fillColor: isLocked
                        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
                        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
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
                  ref.read(paramPanelProvider.notifier).toggleLock(item.param.paramName);
                },
                color: isLocked ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              LamiIcon(
                icon: Icons.restart_alt_rounded,
                size: 18,
                padding: 8,
                onPressed: () {
                  ref.read(paramPanelProvider.notifier).resetParamValue(item.param.paramName);
                },
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            "CONSTRAINTS (THRESH)",
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              Expanded(
                child: _ConstraintItem(label: "MIN", value: "0.0"),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: _ConstraintItem(label: "MAX", value: "10.0"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConstraintItem extends StatelessWidget {
  final String label;
  final String value;

  const _ConstraintItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9.0,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11.0,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
