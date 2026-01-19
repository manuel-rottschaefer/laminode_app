import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/presentation/widgets/fog_effect.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class LamiDialogModel {
  final String title;
  final Widget content;
  final List<Widget>? actions;
  final bool dismissible;

  const LamiDialogModel({
    required this.title,
    required this.content,
    this.actions,
    this.dismissible = true,
  });
}

class LamiDialog extends StatelessWidget {
  final LamiDialogModel model;

  const LamiDialog({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: FogEffect(
          padding: AppSpacing.l,
          color: colorScheme.surfaceContainer,
          child: LamiPanel(
            baseRadius: 12,
            borderWidth: 3,
            internalPadding: const EdgeInsets.all(AppSpacing.l),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [model.content],
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showLamiDialog<T>({
  required BuildContext context,
  required LamiDialogModel model,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: model.dismissible,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => LamiDialog(model: model),
  );
}
