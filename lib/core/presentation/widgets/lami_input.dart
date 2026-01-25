import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/lami_input_decoration.dart';

class LamiInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool isMonospace;
  final double fontSize;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;

  const LamiInput({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.onChanged,
    this.enabled = true,
    this.isMonospace = false,
    this.fontSize = 13,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      onTap: onTap,
      readOnly: readOnly,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontFamily: isMonospace ? 'monospace' : null,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: enabled ? null : colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      decoration: LamiInputDecoration.decoration(
        context,
        label: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabled: enabled,
      ),
    );
  }
}