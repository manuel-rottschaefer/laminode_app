import 'package:flutter/material.dart';

class SelectDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;

  const SelectDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.label,
    this.selectedItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
        ],
        InputDecorator(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              selectedItemBuilder: selectedItemBuilder,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }
}
