import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class LamiDialogLayout extends StatelessWidget {
  final List<Widget> children;
  final List<Widget>? actions;

  const LamiDialogLayout({super.key, required this.children, this.actions});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.l,
              children: children,
            ),
          ),
        ),
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s),
          Row(
            children: [
              actions!.first,
              const Spacer(),
              if (actions!.length > 1)
                ...actions!
                    .sublist(1)
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.s),
                        child: a,
                      ),
                    ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
        ],
      ],
    );
  }
}
