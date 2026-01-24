import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';

class AdapterEditorWidget extends ConsumerStatefulWidget {
  const AdapterEditorWidget({super.key});

  @override
  ConsumerState<AdapterEditorWidget> createState() =>
      _AdapterEditorWidgetState();
}

class _AdapterEditorWidgetState extends ConsumerState<AdapterEditorWidget> {
  CodeController? _codeController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialCode = ref.read(schemaEditorProvider).adapterCode;
    _codeController = CodeController(text: initialCode, language: javascript);
    // Sync external changes if needed? For now assume local state is primary until save.
  }

  @override
  void dispose() {
    _codeController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 32,
          child: Row(
            children: [
              Text(
                'ADAPTER LOGIC (JAVASCRIPT)',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF23241f), // Monokai-ish
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CodeField(
                controller: _codeController!,
                focusNode: _focusNode,
                textStyle: const TextStyle(fontFamily: 'monospace'),
                lineNumberStyle: const LineNumberStyle(width: 40, margin: 8),
                onChanged: (val) {
                  ref
                      .read(schemaEditorProvider.notifier)
                      .updateAdapterCode(val);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
