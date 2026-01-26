import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

enum LamiSectionHeaderSize { small, large }

class LamiSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final LamiSectionHeaderSize size;

  const LamiSectionHeader.small({
    super.key,
    required this.title,
    required this.icon,
    this.trailing,
  }) : size = LamiSectionHeaderSize.small;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isLarge = size == LamiSectionHeaderSize.large;

    return Padding(
      padding: EdgeInsets.only(
        left: 4,
        bottom: isLarge ? AppSpacing.l : AppSpacing.s,
        right: 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null && !isLarge) ...[
            Icon(
              icon,
              size: 18,
              color: colorScheme.primary.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: isLarge
                  ? theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    )
                  : theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      letterSpacing: 0.8,
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.s),
            trailing!,
          ],
        ],
      ),
    );
  }
}
