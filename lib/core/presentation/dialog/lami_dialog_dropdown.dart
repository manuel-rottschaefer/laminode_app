import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_input.dart';

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
