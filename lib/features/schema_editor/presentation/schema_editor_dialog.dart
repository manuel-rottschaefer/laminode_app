import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_segmented_control.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/schema_properties_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/categories_editor_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/adapter_editor_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_list_widget.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/param_conf_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SchemaEditorDialog extends ConsumerWidget {
  final VoidCallback onSave;

  const SchemaEditorDialog({super.key, required this.onSave});

  Widget buildNavigator(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final viewMode = ref.watch(
          schemaEditorProvider.select((s) => s.viewMode),
        );
        return SizedBox(
          width: 240,
          child: LamiSegmentedControl<SchemaEditorViewMode>(
            selectedValue: viewMode,
            onSelected: (mode) {
              ref.read(schemaEditorProvider.notifier).setViewMode(mode);
            },
            segments: const [
              LamiSegment(
                value: SchemaEditorViewMode.schema,
                icon: LucideIcons.layout,
                tooltip: "Schema & Adapter",
              ),
              LamiSegment(
                value: SchemaEditorViewMode.parameters,
                icon: LucideIcons.list,
                tooltip: "Parameters",
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(schemaEditorProvider.select((s) => s.viewMode));

    return SizedBox(
      height: 700,
      width: 1200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Expanded(child: _buildBody(context, viewMode)),
          const SizedBox(height: AppSpacing.l),
          Row(
            children: [
              LamiButton(
                label: "Discard & Close",
                icon: LucideIcons.trash2,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Spacer(),
              LamiButton(
                label: "Export Bundle",
                icon: LucideIcons.download,
                onPressed: () {
                  ref.read(schemaEditorProvider.notifier).exportSchema();
                },
              ),
              const SizedBox(width: AppSpacing.m),
              LamiButton(
                label: "Save Schema",
                icon: LucideIcons.save,
                onPressed: () {
                  onSave();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext ctx, SchemaEditorViewMode viewMode) {
    switch (viewMode) {
      case SchemaEditorViewMode.schema:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left side: Properties (Top) + Categories (Bottom)
            Expanded(
              flex: 4,
              child: Column(
                children: const [
                  SchemaPropertiesWidget(),
                  SizedBox(height: AppSpacing.xl),
                  Expanded(child: CategoriesEditorWidget()),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            // Right side: Adapter Code
            const Expanded(flex: 6, child: AdapterEditorWidget()),
          ],
        );
      case SchemaEditorViewMode.parameters:
        final theme = Theme.of(ctx);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 32,
                    child: Row(
                      children: [
                        Text(
                          "SCHEMA PARAMETERS",
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  const Expanded(child: ParamListWidget()),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              flex: 6,
              child: Consumer(
                builder: (context, ref, _) {
                  final selectedParam = ref.watch(
                    schemaEditorProvider.select(
                      (s) => s.selectedParameter?.paramName,
                    ),
                  );
                  return ParamConfWidget(key: ValueKey(selectedParam));
                },
              ),
            ),
          ],
        );
    }
  }
}
