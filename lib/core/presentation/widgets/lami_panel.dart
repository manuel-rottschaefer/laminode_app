import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_section_header.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class LamiPanel extends StatelessWidget {
  final Widget child;
  final double baseRadius;
  final double borderWidth;
  final EdgeInsetsGeometry? internalPadding;

  const LamiPanel({
    super.key,
    required this.child,
    this.baseRadius = AppSpacing.m,
    this.borderWidth = AppSpacing.xs,
    this.internalPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          padding: EdgeInsets.all(borderWidth),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(baseRadius),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: internalPadding ?? const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(baseRadius),
                topRight: Radius.circular(baseRadius + borderWidth),
                bottomLeft: Radius.circular(baseRadius + borderWidth),
                bottomRight: Radius.circular(baseRadius),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class LamiPanelHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const LamiPanelHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return LamiSectionHeader.small(
      title: title,
      icon: icon,
      trailing: trailing,
    );
  }
}
