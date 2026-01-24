import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class ParamNodeActionBar extends StatelessWidget {
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onToggleLock;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ParamNodeActionBar({
    super.key,
    this.onMoveUp,
    this.onMoveDown,
    this.onToggleLock,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LamiIconButton(
            icon: Icons.arrow_upward_rounded,
            onPressed: onMoveUp,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.s),
          LamiIconButton(
            icon: Icons.arrow_downward_rounded,
            onPressed: onMoveDown,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.s),
          LamiIconButton(
            icon: Icons.lock_open_rounded,
            onPressed: onToggleLock,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.s),
          LamiIconButton(
            icon: Icons.edit_rounded,
            onPressed: onEdit,
            size: 16,
            color: Colors.white,
          ),
          const SizedBox(width: AppSpacing.s),
          LamiIconButton(
            icon: Icons.delete_outline_rounded,
            onPressed: onDelete,
            size: 16,
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
