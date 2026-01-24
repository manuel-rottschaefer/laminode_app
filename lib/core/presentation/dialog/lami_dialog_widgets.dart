import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

export 'lami_dialog_input.dart';
export 'lami_dialog_dropdown.dart';

class LamiDialogHeader extends StatelessWidget {
  final String title;
  final Widget? leading;
  final bool dismissible;

  const LamiDialogHeader({
    super.key,
    required this.title,
    this.leading,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (leading != null)
            Align(alignment: Alignment.centerLeft, child: leading!),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          if (dismissible)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
        ],
      ),
    );
  }
}

class LamiDialogForm extends StatelessWidget {
  final List<Widget> children;

  const LamiDialogForm({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.m,
      children: children,
    );
  }
}

class LamiDialogActions extends StatelessWidget {
  final List<Widget> actions;

  const LamiDialogActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: AppSpacing.m,
      children: [
        actions.first,
        const Spacer(),
        if (actions.length > 1) ...actions.sublist(1),
      ],
    );
  }
}
