import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dialog_layout.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path/path.dart' as p;

class CreateProfileDialog extends ConsumerStatefulWidget {
  const CreateProfileDialog({super.key});

  @override
  ConsumerState<CreateProfileDialog> createState() =>
      _CreateProfileDialogState();
}

class _CreateProfileDialogState extends ConsumerState<CreateProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  PluginManifest? _selectedApplication;
  String? _selectedSchemaId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        _locationController.text = result;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedApplication != null) {
      ProfileSchemaManifest? schemaManifest;
      if (_selectedSchemaId != null) {
        final schemaRef = _selectedApplication!.schemas.firstWhere(
          (s) => s.id == _selectedSchemaId,
        );
        schemaManifest = ProfileSchemaManifest(
          id: schemaRef.id,
          version: schemaRef.version,
          updated: schemaRef.releaseDate,
          targetAppName: _selectedApplication!.displayName,
          type: _selectedApplication!.pluginType,
        );
      }

      final profile = ProfileEntity(
        name: _nameController.text,
        description: _descriptionController.text,
        application: ProfileApplication.fromManifest(_selectedApplication!),
        path: p.join(_locationController.text, "${_nameController.text}.lmdp"),
        schema: schemaManifest,
      );

      ref.read(profileManagerProvider.notifier).createProfile(profile);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final installedApps = ref.watch(installedApplicationsProvider);

    return Form(
      key: _formKey,
      child: LamiDialogLayout(
        actions: [
          LamiButton(
            icon: LucideIcons.x,
            label: "Cancel",
            onPressed: () => Navigator.of(context).pop(),
          ),
          LamiButton(
            icon: LucideIcons.check,
            label: "Create",
            onPressed: _submit,
          ),
        ],
        children: [
          LamiDialogInput(
            label: "Profile Name",
            controller: _nameController,
            hintText: "Enter profile name",
            prefixIcon: const Icon(LucideIcons.tag, size: 18),
            validator: (v) => v?.isEmpty ?? true ? "Name is required" : null,
          ),
          LamiDialogInput(
            label: "Description (Optional)",
            controller: _descriptionController,
            maxLines: 2,
            hintText: "What is this profile for?",
            prefixIcon: const Icon(LucideIcons.fileText, size: 18),
          ),
          LamiDialogDropdown<PluginManifest>(
            label: "Application",
            value: _selectedApplication,
            prefixIcon: const Icon(LucideIcons.layers, size: 18),
            hintText: "Select an application",
            items: installedApps.map((app) {
              return DropdownMenuItem(value: app, child: Text(app.displayName));
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedApplication = val;
                _selectedSchemaId = (val != null && val.schemas.isNotEmpty)
                    ? val.schemas.first.id
                    : null;
              });
            },
            validator: (v) => v == null ? "Application is required" : null,
          ),
          if (_selectedApplication != null &&
              _selectedApplication!.schemas.isNotEmpty)
            LamiDialogDropdown<String>(
              label: "Schema",
              value: _selectedSchemaId,
              prefixIcon: const Icon(LucideIcons.binary, size: 18),
              hintText: "Select a schema",
              items: _selectedApplication!.schemas.map((schema) {
                return DropdownMenuItem(
                  value: schema.id,
                  child: Text("${schema.id} (v${schema.version})"),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedSchemaId = val),
              validator: (v) => v == null ? "Schema is required" : null,
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.l),
            child: InkWell(
              onTap: _pickLocation,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: LamiDialogInput.decoration(
                  context,
                  label: "Save Location",
                  prefixIcon: const Icon(LucideIcons.folder, size: 18),
                  suffixIcon: const Icon(LucideIcons.search, size: 18),
                ),
                child: Text(
                  _locationController.text.isEmpty
                      ? "Select folder..."
                      : _locationController.text,
                  style: _locationController.text.isEmpty
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        )
                      : theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
