import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dialog_layout.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/schema_selection_item.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/schema_edit_manager.dart';

import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';

class SchemaSelectionDialog extends ConsumerWidget {
  final String applicationId;
  final String? selectedSchemaId;
  final Function(ProfileSchemaManifest) onSchemaSelected;

  const SchemaSelectionDialog({
    super.key,
    required this.applicationId,
    this.selectedSchemaId,
    required this.onSchemaSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemas = ref.watch(installedSchemasForAppProvider(applicationId));
    final shopState = ref.watch(schemaShopProvider);
    final installedPlugins = shopState.installedPlugins;

    final plugin = installedPlugins.cast<PluginManifest?>().firstWhere(
      (p) => p?.plugin.pluginID == applicationId,
      orElse: () => null,
    );

    return LamiDialogLayout(
      children: [
        if (shopState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          )
        else if (plugin == null)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text("Application details not found."),
            ),
          )
        else if (schemas.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text("No schemas installed for this application."),
            ),
          )
        else
          ...schemas.map((schema) {
            return SchemaSelectionItem(
              schema: schema,
              isSelected: schema.id == selectedSchemaId,
              onTap: () {
                onSchemaSelected(
                  ProfileSchemaManifest(
                    id: schema.id,
                    version: schema.version,
                    updated: schema.releaseDate,
                    targetAppName: plugin.displayName,
                    type: plugin.pluginType,
                  ),
                );
                Navigator.of(context).pop();
              },
              onEdit: () =>
                  SchemaEditManager.editSchema(context, ref, schema.id),
            );
          }),
      ],
    );
  }
}
