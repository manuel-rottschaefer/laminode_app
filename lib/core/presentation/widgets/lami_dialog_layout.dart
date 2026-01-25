import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class LamiDialogLayout extends StatelessWidget {
  final List<Widget> children;
  final List<Widget>? actions;
  final bool scrollable;
  final MainAxisSize mainAxisSize;

  const LamiDialogLayout({
    super.key,
    required this.children,
    this.actions,
    this.scrollable = false,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.l,
      children: children,
    );

    if (scrollable) {
      content = SingleChildScrollView(child: content);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(child: content),
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: AppSpacing.m,
            children: [
              actions!.first,
              const Spacer(),
              if (actions!.length > 1) ...actions!.sublist(1),
            ],
          ),
        ],
      ],
    );
  }
}
