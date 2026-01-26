import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SchemaEditorFooter extends ConsumerWidget {
  const SchemaEditorFooter({super.key});

  Future<bool> _confirmOverwrite(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Overwrite Existing Schema?"),
        content: const Text(
          "A schema with this ID for this application version already exists. Overwriting will replace the existing files. Do you want to continue?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Overwrite"),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSave = ref.watch(schemaEditorProvider.select((s) => s.canSave));
    final appExists = ref.watch(
      schemaEditorProvider.select((s) => s.appExists),
    );
    final versionExists = ref.watch(
      schemaEditorProvider.select((s) => s.versionExists),
    );
    final isChecking = ref.watch(
      schemaEditorProvider.select((s) => s.isChecking),
    );

    return Row(
      children: [
        LamiButton(
          label: "Discard & Close",
          icon: LucideIcons.trash2,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const Spacer(),
        if (isChecking)
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.m),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (!appExists && !isChecking)
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.m),
            child: Text(
              "Application not installed",
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ),
        if (versionExists && !isChecking)
          const Padding(
            padding: EdgeInsets.only(right: AppSpacing.m),
            child: Text(
              "Version already exists",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        LamiButton(
          label: "Export Bundle",
          icon: LucideIcons.upload,
          onPressed: () {
            ref.read(schemaEditorProvider.notifier).exportSchema();
          },
        ),
        const SizedBox(width: AppSpacing.m),
        LamiButton(
          label: "Save Schema",
          icon: LucideIcons.save,
          inactive: !canSave,
          onPressed: () async {
            if (versionExists) {
              final confirmed = await _confirmOverwrite(context);
              if (!confirmed) return;
            }

            try {
              await ref.read(schemaEditorProvider.notifier).saveSchema();
              if (context.mounted) Navigator.of(context).pop();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
              }
            }
          },
        ),
        const SizedBox(width: AppSpacing.m),
        LamiButton(
          label: "Save & Use Schema",
          icon: LucideIcons.play,
          inactive: !canSave,
          onPressed: () async {
            if (versionExists) {
              final confirmed = await _confirmOverwrite(context);
              if (!confirmed) return;
            }

            try {
              await ref.read(schemaEditorProvider.notifier).saveAndUseSchema();
              if (context.mounted) Navigator.of(context).pop();
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to save & use: $e")),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
