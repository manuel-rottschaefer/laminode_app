import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';

class LamiDialogHeader extends StatelessWidget {
  final String title;
  final bool dismissible;

  const LamiDialogHeader({
    super.key,
    required this.title,
    this.dismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          if (dismissible)
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

class LamiDialogInput extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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

class LamiDialogDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final String? hintText;

  const LamiDialogDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.value,
    this.validator,
    this.prefixIcon,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        decoration: LamiDialogInput.decoration(
          context,
          label: label,
          hintText: hintText,
          prefixIcon: prefixIcon,
          isDense: true,
        ),
        hint: hintText != null ? Text(hintText!) : null,
      ),
    );
  }
}

class LamiDialogForm extends StatelessWidget {
  final List<Widget> children;

  const LamiDialogForm({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.m,
      children: children,
    );
  }
}

class LamiDialogActions extends StatelessWidget {
  final List<Widget> actions;

  const LamiDialogActions({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: AppSpacing.m,
      children: [
        actions.first,
        const Spacer(),
        if (actions.length > 1) ...actions.sublist(1),
      ],
    );
  }
}
