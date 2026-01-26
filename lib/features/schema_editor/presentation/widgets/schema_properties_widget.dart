import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dropdown.dart';

class SchemaPropertiesWidget extends ConsumerStatefulWidget {
  const SchemaPropertiesWidget({super.key});

  @override
  ConsumerState<SchemaPropertiesWidget> createState() =>
      _SchemaPropertiesWidgetState();
}

class _SchemaPropertiesWidgetState
    extends ConsumerState<SchemaPropertiesWidget> {
  late TextEditingController _versionController;
  late TextEditingController _appVersionController;
  late TextEditingController _authorsController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(schemaEditorProvider);
    _versionController = TextEditingController(
      text: state.manifest.schemaVersion,
    );
    _appVersionController = TextEditingController(
      text: state.manifest.targetAppVersion ?? '1.0',
    );
    _authorsController = TextEditingController(
      text: state.manifest.schemaAuthors.join(', '),
    );
  }

  @override
  void dispose() {
    _versionController.dispose();
    _appVersionController.dispose();
    _authorsController.dispose();
    super.dispose();
  }

  void _updateManifest({String? targetAppName}) {
    final authors = _authorsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final state = ref.read(schemaEditorProvider);

    ref
        .read(schemaEditorProvider.notifier)
        .updateManifest(
          targetAppName: targetAppName ?? state.manifest.targetAppName,
          targetAppVersion: _appVersionController.text,
          schemaVersion: _versionController.text,
          schemaAuthors: authors,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(schemaEditorProvider);
    final installedApps = ref.watch(installedApplicationsProvider);

    final appNames = installedApps
        .map((app) => app.application?.appName ?? app.displayName)
        .toSet()
        .toList();

    final currentApp = state.manifest.targetAppName;
    if (currentApp != null &&
        currentApp.isNotEmpty &&
        !appNames.contains(currentApp)) {
      appNames.insert(0, currentApp);
    }

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
              LamiDropdown<String>(
                label: 'Target Application Name',
                value: currentApp,
                items: appNames.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
                onChanged: (val) => _updateManifest(targetAppName: val),
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: LamiDialogInput(
                      label: 'App Version',
                      controller: _appVersionController,
                      onChanged: (_) => _updateManifest(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: LamiDialogInput(
                      label: 'Schema Version',
                      controller: _versionController,
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
