import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/presentation/schema_editor_dialog.dart';
import 'package:laminode_app/features/schema_shop/data/models/schema_manifest_model.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';

class SchemaEditManager {
  static Future<void> editSchema(
    BuildContext context,
    WidgetRef ref,
    String schemaId,
  ) async {
    try {
      final repo = ref.read(schemaShopRepositoryProvider);
      final schemaEntry = await repo.loadInstalledSchema(schemaId);
      final rawSchema = await repo.getRawSchema(schemaId);
      final adapterCode = await repo.getAdapterCodeForSchema(schemaId);

      if (schemaEntry == null) {
        throw Exception("Schema entry not found");
      }

      final manifestJson = rawSchema?['manifest'] ?? {};
      final manifest = SchemaManifestModel.fromJson(manifestJson);

      ref
          .read(schemaEditorProvider.notifier)
          .loadSchema(
            schemaEntry,
            manifest,
            adapterCode: adapterCode ?? "// Adapter code not found",
          );

      if (context.mounted) {
        final editor = SchemaEditorDialog(
          onSave: () async {
            try {
              final state = ref.read(schemaEditorProvider);
              final newSchemaJson = _schemaToJson(state);

              // Use updated targetAppName from manifest
              final targetAppName = state.manifest.targetAppName ?? 'Unknown';

              await repo.saveSchema(
                targetAppName,
                schemaId,
                newSchemaJson,
                state.adapterCode,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Schema saved successfully")),
                );
                // Refresh schemas
                ref.invalidate(schemaShopProvider);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to save schema: $e")),
                );
              }
            }
          },
        );

        showLamiDialog(
          context: context,
          useRootNavigator: false,
          model: LamiDialogModel(
            title: "Edit Schema: ${schemaEntry.schemaName}",
            maxWidth: 1200,
            leading: editor.buildNavigator(ref),
            insetPadding: const EdgeInsets.fromLTRB(40, 80, 40, 24),
            content: editor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load schema: $e")));
      }
    }
  }

  static Map<String, dynamic> _schemaToJson(SchemaEditorState state) {
    // Update lastUpdated
    final updatedManifest = SchemaManifestModel(
      schemaType: state.manifest.schemaType,
      schemaVersion: state.manifest.schemaVersion,
      schemaAuthors: state.manifest.schemaAuthors,
      lastUpdated: DateTime.now().toIso8601String(),
      targetAppName: state.manifest.targetAppName,
      targetAppSector: state.manifest.targetAppSector,
    );

    return {
      'manifest': updatedManifest.toJson(),
      'categories': state.schema.categories
          .map(
            (c) => {
              'name': c.categoryName,
              'title': c.categoryTitle,
              'color': c.categoryColorName,
            },
          )
          .toList(),
      'availableParameters': state.schema.availableParameters
          .map(
            (p) => {
              'name': p.paramName,
              'title': p.paramTitle,
              'description': p.paramDescription,
              'category': p.category.categoryName,
              'baseParam': p.baseParam,
              'quantity': {
                'name': p.quantity.quantityName,
                'unit': p.quantity.quantityUnit,
                'symbol': p.quantity.quantitySymbol,
                'type': p.quantity.quantityType.name,
              },
            },
          )
          .toList(),
    };
  }
}
