import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/presentation/widgets/fog_effect.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';

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
        constraints: const BoxConstraints(maxWidth: 550),
        child: FogEffect(
          padding: AppSpacing.xl,
          color: colorScheme.surfaceContainer,
          child: LamiPanel(
            baseRadius: 24,
            borderWidth: 5,
            internalPadding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LamiDialogHeader(
                  title: model.title,
                  dismissible: model.dismissible,
                ),
                Flexible(child: model.content),
                if (model.actions != null && model.actions!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.l),
                  Row(
                    children: [
                      model.actions!.first,
                      const Spacer(),
                      if (model.actions!.length > 1)
                        ...model.actions!
                            .sublist(1)
                            .map(
                              (a) => Padding(
                                padding: const EdgeInsets.only(
                                  left: AppSpacing.s,
                                ),
                                child: a,
                              ),
                            ),
                    ],
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
