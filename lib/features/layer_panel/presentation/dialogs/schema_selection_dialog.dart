import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/schema_selection_item.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/schema_edit_manager.dart';

class SchemaSelectionDialog extends ConsumerWidget {
  final String applicationId;
  final String? selectedSchemaId;
  final Function(String) onSchemaSelected;

  const SchemaSelectionDialog({
    super.key,
    required this.applicationId,
    this.selectedSchemaId,
    required this.onSchemaSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schemas = ref.watch(installedSchemasForAppProvider(applicationId));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (schemas.isEmpty)
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
                onSchemaSelected(schema.id);
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
