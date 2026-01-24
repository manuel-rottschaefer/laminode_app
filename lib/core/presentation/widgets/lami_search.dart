import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';

class LamiSearch extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final FocusNode? focusNode;

  const LamiSearch({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
    this.focusNode,
  });

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
          Icon(
            Icons.search_rounded,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText ?? 'Search...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor.withValues(alpha: 0.5),
                ),
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
