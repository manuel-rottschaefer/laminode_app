import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/evaluation/application/expression_parser.dart';

class CamParamExpressionInput extends StatefulWidget {
  final String label;
  final String expression;
  final CamSchemaEntry schema;
  final ValueChanged<String> onChanged;

  const CamParamExpressionInput({
    super.key,
    required this.label,
    required this.expression,
    required this.schema,
    required this.onChanged,
  });

  @override
  State<CamParamExpressionInput> createState() =>
      _CamParamExpressionInputState();
}

class _CamParamExpressionInputState extends State<CamParamExpressionInput> {
  late CodeController _codeController;
  final ExpressionParser _parser = ExpressionParser();
  List<String> _detectedParams = [];

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.expression,
      language: javascript,
      patternMap: {},
    );
    _analyzeExpression(widget.expression);
  }

  @override
  void didUpdateWidget(CamParamExpressionInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expression != oldWidget.expression &&
        widget.expression != _codeController.text) {
      _codeController.text = widget.expression;
      _analyzeExpression(widget.expression);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _analyzeExpression(String text) {
    final extracted = _parser.extractVariableNames(text);
    final paramNames = widget.schema.availableParameters
        .map((p) => p.paramName)
        .toSet();

    final detected = extracted.intersection(paramNames).toList();
    detected.sort();

    // Color detected parameters green
    final styles = {
      for (final p in detected)
        '\\b$p\\b': const TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.bold,
        ),
    };

    if (detected.join(',') != _detectedParams.join(',') ||
        text != _codeController.text) {
      _codeController.patternMap?.clear();
      _codeController.patternMap?.addAll(styles);
      _codeController.value = _codeController.value;
      setState(() {
        _detectedParams = detected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = _codeController.text.trim().isNotEmpty;
    final lineCount = _codeController.text.split('\n').length;
    final effectiveHeight = !hasContent
        ? 48.0
        : (lineCount <= 1 ? 56.0 : 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CodeField(
              controller: _codeController,
              textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onChanged: (val) {
                _analyzeExpression(val);
                widget.onChanged(val);
                setState(() {}); // Rebuild for height change
              },
            ),
          ),
        ),
        if (_detectedParams.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  "Detected Parameters:",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ..._detectedParams.map(
                  (p) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      p,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 9,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.m),
      ],
    );
  }
}
