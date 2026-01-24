import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';

class SchemaPropertiesWidget extends ConsumerStatefulWidget {
  const SchemaPropertiesWidget({super.key});

  @override
  ConsumerState<SchemaPropertiesWidget> createState() =>
      _SchemaPropertiesWidgetState();
}

class _SchemaPropertiesWidgetState
    extends ConsumerState<SchemaPropertiesWidget> {
  late TextEditingController _nameController;
  late TextEditingController _versionController;
  late TextEditingController _authorsController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(schemaEditorProvider);
    _nameController = TextEditingController(
      text: state.manifest.targetAppName ?? '',
    );
    _versionController = TextEditingController(
      text: state.manifest.schemaVersion,
    );
    _authorsController = TextEditingController(
      text: state.manifest.schemaAuthors.join(', '),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _versionController.dispose();
    _authorsController.dispose();
    super.dispose();
  }

  void _updateManifest() {
    final authors = _authorsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    ref
        .read(schemaEditorProvider.notifier)
        .updateManifest(
          targetAppName: _nameController.text,
          schemaVersion: _versionController.text,
          schemaAuthors: authors,
        );
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
                "SCHEMA PROPERTIES",
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        LamiBox(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: LamiDialogInput(
                      label: 'Version',
                      controller: _versionController,
                      onChanged: (_) => _updateManifest(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    flex: 5,
                    child: LamiDialogInput(
                      label: 'Target Application Name',
                      controller: _nameController,
                      onChanged: (_) => _updateManifest(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              LamiDialogInput(
                label: 'Authors (comma separated)',
                controller: _authorsController,
                onChanged: (_) => _updateManifest(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
