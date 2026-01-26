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
              letterSpacing: 1.2,
            ),
          ),
          if (dismissible)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, size: 24),
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
        ],
      ),
    );
  }
}
