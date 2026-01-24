import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class LamiDialogInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const LamiDialogInput({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.autofocus = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
  });

  static InputDecoration decoration(
    BuildContext context, {
    required String label,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDense = false,
    bool alignLabelWithHint = false,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      isDense: isDense,
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: Colors.transparent,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      floatingLabelStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: TextFormField(
        controller: controller,
        autofocus: autofocus,
        maxLines: maxLines,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
        decoration: decoration(
          context,
          label: label,
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          alignLabelWithHint: maxLines > 1,
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        validator: validator,
      ),
    );
  }
}
