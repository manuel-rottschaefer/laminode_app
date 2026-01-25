import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/lami_input_decoration.dart';

class LamiDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String label;
  final String? hintText;
  final bool enabled;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final Widget? prefixIcon;

  const LamiDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    required this.label,
    this.hintText,
    this.enabled = true,
    this.selectedItemBuilder,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      selectedItemBuilder: selectedItemBuilder,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 20,
        color: colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: enabled ? null : colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      decoration: LamiInputDecoration.decoration(
        context,
        label: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        enabled: enabled,
      ),
    );
  }
}
