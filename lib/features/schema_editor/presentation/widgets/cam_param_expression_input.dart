import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/theme/app_colors.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/evaluation/application/expression_parser.dart';
import 'package:laminode_app/features/evaluation/application/providers.dart';
import 'package:laminode_app/features/evaluation/domain/expression_validation_result.dart';

class CamParamExpressionInput extends ConsumerStatefulWidget {
  final String label;
  final String expression;
  final CamSchemaEntry schema;
  final ValueChanged<String> onChanged;
  final QuantityType? expectedQuantityType;
  final bool isCondition;
  final String expressionLang;

  const CamParamExpressionInput({
    super.key,
    required this.label,
    required this.expression,
    required this.schema,
    required this.onChanged,
    this.expectedQuantityType,
    this.isCondition = false,
    this.expressionLang = 'js',
  });

  @override
  ConsumerState<CamParamExpressionInput> createState() =>
      _CamParamExpressionInputState();
}

class _CamParamExpressionInputState
    extends ConsumerState<CamParamExpressionInput> {
  late CodeController _codeController;
  final ExpressionParser _parser = ExpressionParser();
  final FocusNode _focusNode = FocusNode();
  List<String> _detectedParams = [];
  bool? _lastIsDark;
  ExpressionValidationResult? _validationResult;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.expression,
      language: javascript,
      patternMap: {},
    );
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _analyzeExpression(_codeController.text);
  }

  @override
  void didUpdateWidget(CamParamExpressionInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.expression != oldWidget.expression &&
        widget.expression != _codeController.text) {
      _codeController.text = widget.expression;
      _analyzeExpression(widget.expression);
      _validateExpression();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateExpression();
    }
  }

  void _validateExpression() {
    final validator = ref.read(expressionValidatorProvider);
    final result = validator.validate(
      _codeController.text,
      widget.schema.availableParameters,
      expectedQuantityType: widget.expectedQuantityType,
      isCondition: widget.isCondition,
    );
    setState(() {
      _validationResult = result;
    });
  }

  void _analyzeExpression(String text) {
    final extracted = _parser.extractVariableNames(text);
    final paramNames = widget.schema.availableParameters
        .map((p) => p.paramName)
        .toSet();

    final detected = extracted.intersection(paramNames).toList();
    detected.sort();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final styles = <String, TextStyle>{};
    for (final pName in detected) {
      final param = widget.schema.availableParameters.firstWhere(
        (p) => p.paramName == pName,
      );
      final categoryColor = LamiColor.fromString(
        param.category.categoryColorName,
      ).value;

      styles['\\b$pName\\b'] = TextStyle(
        color: categoryColor,
        fontWeight: FontWeight.bold,
      );
    }

    if (detected.join(',') != _detectedParams.join(',') ||
        text != _codeController.text ||
        isDark != _lastIsDark) {
      _codeController.patternMap?.clear();
      _codeController.patternMap?.addAll(styles);
      _codeController.value = _codeController.value;

      // Use addPostFrameCallback if called from didChangeDependencies to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _detectedParams = detected;
            _lastIsDark = isDark;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasContent = _codeController.text.trim().isNotEmpty;
    final lineCount = _codeController.text.split('\n').length;
    final effectiveHeight = !hasContent
        ? 54.0
        : (lineCount <= 1 ? 68.0 : 124.0);

    final isValid = _validationResult?.isValid ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.expressionLang.isNotEmpty)
              Text(
                widget.expressionLang.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: effectiveHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: isDark ? 0.3 : 0.6,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isValid
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.15)
                  : theme.colorScheme.error.withValues(alpha: 0.5),
              width: isValid ? 1 : 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CodeField(
              controller: _codeController,
              focusNode: _focusNode,
              background: Colors.transparent,
              textStyle: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              onChanged: (val) {
                _analyzeExpression(val);
                widget.onChanged(val);
                setState(() {}); // Rebuild for height change
              },
            ),
          ),
        ),
        if (!isValid && _validationResult?.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              _validationResult!.errorMessage!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
                fontSize: 10,
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
