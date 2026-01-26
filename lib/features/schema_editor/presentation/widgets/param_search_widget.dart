import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';

class ParamSearchWidget extends StatefulWidget {
  final List<CamParamEntry> allParameters;
  final ValueChanged<CamParamEntry?> onSelected;
  final String? hostParamName;
  final String? label;

  const ParamSearchWidget({
    super.key,
    required this.allParameters,
    required this.onSelected,
    this.hostParamName,
    this.label,
  });

  @override
  State<ParamSearchWidget> createState() => ParamSearchWidgetState();
}

class ParamSearchWidgetState extends State<ParamSearchWidget> {
  final TextEditingController _controller = TextEditingController();
  List<CamParamEntry> _suggestions = [];
  CamParamEntry? _selectedParam;

  void clear() {
    _controller.clear();
    setState(() {
      _suggestions = [];
      _selectedParam = null;
    });
    widget.onSelected(null);
  }

  void _onQueryChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _selectedParam = null;
      });
      widget.onSelected(null);
      return;
    }

    final filtered = widget.allParameters.where((p) {
      if (p.paramName == widget.hostParamName) return false;
      return p.paramName.toLowerCase().contains(query.toLowerCase()) ||
          p.paramTitle.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _suggestions = filtered;
    });

    // Automatically select if exact match on name
    final exact = filtered
        .where((p) => p.paramName == query.trim())
        .firstOrNull;
    if (exact != null && exact != _selectedParam) {
      _select(exact);
    } else if (exact == null && _selectedParam != null) {
      setState(() => _selectedParam = null);
      widget.onSelected(null);
    }
  }

  void _select(CamParamEntry param) {
    setState(() {
      _selectedParam = param;
      _controller.text = param.paramName;
      _suggestions = [];
    });
    widget.onSelected(param);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isValid = _selectedParam != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Stack(
          alignment: Alignment.centerRight,
          children: [
            LamiSearch(
              controller: _controller,
              hintText: "Enter parameter ID or Title...",
              onChanged: _onQueryChanged,
            ),
            if (isValid)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Colors.green,
                ),
              ),
          ],
        ),
        if (_suggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.take(6).map((p) {
                return InkWell(
                  onTap: () => _select(p),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.paramTitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          p.paramName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 9,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
