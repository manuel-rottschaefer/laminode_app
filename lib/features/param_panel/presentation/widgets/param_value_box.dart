import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_value_input.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_value_constraints.dart';

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
    final initialValue =
        (widget.item.param.value ?? widget.item.param.evalSuggest()).toString();
    _controller = TextEditingController(text: initialValue);
  }

  @override
  void didUpdateWidget(ParamValueBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newValue =
        (widget.item.param.value ?? widget.item.param.evalSuggest()).toString();
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
          ParamValueInput(item: widget.item, controller: _controller),
          const SizedBox(height: AppSpacing.m),
          const ParamValueConstraints(),
        ],
      ),
    );
  }
}
