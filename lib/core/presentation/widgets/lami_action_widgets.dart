import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';

class LamiButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool inactive;

  const LamiButton({super.key, required this.icon, required this.label, this.onPressed, this.inactive = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null && !inactive;

    return LamiBox(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: enabled ? onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: enabled ? theme.colorScheme.primary.withValues(alpha: 0.9) : theme.disabledColor,
                  size: 14,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: enabled ? theme.colorScheme.onSurface.withValues(alpha: 0.9) : theme.disabledColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LamiIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final double padding;
  final double borderRadius;

  const LamiIcon({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 18,
    this.padding = 6.0,
    this.borderRadius = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Icon(icon, size: size, color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
      ),
    );
  }
}

class LamiIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final double padding;
  final double borderRadius;
  final double borderWidth;
  final Color? backgroundColor;

  const LamiIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 18,
    this.padding = 6.0,
    this.borderRadius = 6.0,
    this.borderWidth = 1.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LamiBox(
      padding: EdgeInsets.zero,
      borderRadius: borderRadius,
      borderWidth: borderWidth,
      backgroundColor: backgroundColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Icon(icon, size: size, color: color ?? theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
        ),
      ),
    );
  }
}

class LamiToggleIcon extends StatelessWidget {
  final bool value;
  final IconData icon;
  final IconData toggledIcon;
  final ValueChanged<bool> onChanged;
  final Color? color;
  final double size;

  const LamiToggleIcon({
    super.key,
    required this.value,
    required this.icon,
    required this.toggledIcon,
    required this.onChanged,
    this.color,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LamiIcon(
      onPressed: () => onChanged(!value),
      icon: value ? toggledIcon : icon,
      size: size,
      color: value ? theme.colorScheme.primary : color,
    );
  }
}

class LamiSearch extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  const LamiSearch({super.key, required this.controller, this.hintText, this.onChanged, this.onClear, this.focusNode});

  @override
  State<LamiSearch> createState() => _LamiSearchState();
}

class _LamiSearchState extends State<LamiSearch> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LamiBox(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor.withValues(alpha: 0.5)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 16),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged?.call('');
                widget.onClear?.call();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              visualDensity: VisualDensity.compact,
              splashRadius: 16,
            ),
        ],
      ),
    );
  }
}
