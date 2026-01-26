import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_segmented_control.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/schema_editor_body.dart';
import 'package:laminode_app/features/schema_editor/presentation/widgets/schema_editor_footer.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SchemaEditorDialog extends ConsumerWidget {
  const SchemaEditorDialog({super.key});

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
          Expanded(child: SchemaEditorBody(viewMode: viewMode)),
          const SizedBox(height: AppSpacing.l),
          const SchemaEditorFooter(),
        ],
      ),
    );
  }
}
