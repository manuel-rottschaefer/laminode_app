import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/dialog/lami_dialog.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
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
        const editor = SchemaEditorDialog();

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

  // _schemaToJson is no longer needed here as it moved to the notifier
}
