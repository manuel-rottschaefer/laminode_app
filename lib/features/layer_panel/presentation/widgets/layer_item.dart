import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';

class LayerItem extends ConsumerStatefulWidget {
  final LamiLayerEntry entry;
  final int index;

  const LayerItem({super.key, required this.entry, required this.index});

  @override
  ConsumerState<LayerItem> createState() => _LayerItemState();
}

class _LayerItemState extends ConsumerState<LayerItem> {
  bool isExpanded = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.m),
      child: LamiBox(
        padding: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                onHover: (hovering) => setState(() => isHovered = hovering),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Row(
                    children: [
                      // Status / Drag Hint
                      AnimatedSize(
                        duration: const Duration(milliseconds: 180),
                        child: SizedBox(
                          width: (isHovered || isExpanded) ? 28 : 0,
                          child: Icon(
                            Icons.drag_handle_rounded,
                            size: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ),

                      // Header Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.entry.layerName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: widget.entry.isActive
                                    ? colorScheme.onSurface
                                    : theme.disabledColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "0 effective parameters",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Toggle Active
                      Transform.scale(
                        scale: 0.7,
                        child: Switch(
                          value: widget.entry.isActive,
                          onChanged: (val) {
                            // Link to provider toggle
                          },
                          activeThumbColor: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (isExpanded) ...[
                const SizedBox(height: AppSpacing.m),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: AppSpacing.m),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _ActionIconButton(
                            icon: widget.entry.isLocked
                                ? Icons.lock_rounded
                                : Icons.lock_open_rounded,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          _ActionIconButton(
                            icon: Icons.edit_rounded,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 8),
                          _ActionIconButton(
                            icon: Icons.delete_outline_rounded,
                            onPressed: () {
                              ref
                                  .read(layerPanelProvider.notifier)
                                  .removeLayer(widget.index);
                            },
                            color: colorScheme.error,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _ActionIconButton(
                            icon: Icons.arrow_upward_rounded,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 4),
                          _ActionIconButton(
                            icon: Icons.arrow_downward_rounded,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  const _ActionIconButton({required this.icon, this.onPressed, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LamiBox(
      padding: EdgeInsets.zero,
      borderRadius: 6,
      borderWidth: 1.0,
      backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.3,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(
              icon,
              size: 16,
              color:
                  color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
