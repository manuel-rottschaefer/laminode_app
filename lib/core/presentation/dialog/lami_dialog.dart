import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_panel.dart';
import 'package:laminode_app/core/presentation/widgets/fog_effect.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';

class LamiDialogModel {
  final String title;
  final Widget content;
  final Widget? leading;
  final List<Widget>? actions;
  final bool dismissible;
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsets? insetPadding;

  const LamiDialogModel({
    required this.title,
    required this.content,
    this.leading,
    this.actions,
    this.dismissible = true,
    this.maxWidth,
    this.maxHeight,
    this.insetPadding,
  });
}

class LamiDialog extends StatelessWidget {
  final LamiDialogModel model;

  const LamiDialog({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding:
          model.insetPadding ??
          const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: model.maxWidth ?? 550,
          maxHeight: model.maxHeight ?? double.infinity,
        ),
        child: FogEffect(
          padding: AppSpacing.xl,
          color: Colors.black.withValues(alpha: 0.6),
          showSolidBase: false,
          child: LamiPanel(
            baseRadius: 24,
            borderWidth: 5,
            internalPadding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LamiDialogHeader(
                  title: model.title,
                  leading: model.leading,
                  dismissible: model.dismissible,
                ),
                if (model.maxHeight != null)
                  Expanded(child: model.content)
                else
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
  bool useRootNavigator = false,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: model.dismissible,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => LamiDialog(model: model),
  );
}
