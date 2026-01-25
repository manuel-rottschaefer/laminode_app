import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_dialog_layout.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/shop_empty_state.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/shop_plugin_list.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';

class SchemaShopDialog extends ConsumerStatefulWidget {
  const SchemaShopDialog({super.key});

  @override
  ConsumerState<SchemaShopDialog> createState() => _SchemaShopDialogState();
}

class _SchemaShopDialogState extends ConsumerState<SchemaShopDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(schemaShopProvider.notifier).fetchPlugins();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showDirectory() async {
    final dir = await getApplicationSupportDirectory();
    await Process.run('xdg-open', [dir.path]);
  }

  Future<void> _uploadManualSchema() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await ref.read(schemaShopProvider.notifier).installManualSchema(file);
    }
  }

  void _install(PluginManifest plugin, String schemaId) {
    ref.read(schemaShopProvider.notifier).installPlugin(plugin, schemaId).then((
      _,
    ) {
      if (mounted && ref.read(schemaShopProvider).error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Successfully installed ${plugin.displayName} - $schemaId',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schemaShopProvider);
    final theme = Theme.of(context);

    final filteredAndGrouped = ref.watch(
      filteredAndGroupedPluginsProvider(_searchController.text),
    );

    return LamiDialogLayout(
      mainAxisSize: MainAxisSize.max,
      actions: [
        LamiButton(
          icon: LucideIcons.logOut,
          label: "Quit",
          onPressed: () => Navigator.of(context).pop(),
        ),
        LamiButton(
          icon: LucideIcons.folder,
          label: "Show Directory",
          onPressed: _showDirectory,
        ),
      ],
      children: [
        Row(
          children: [
            Expanded(
              child: LamiSearch(
                controller: _searchController,
                hintText: "Search plugins and sectors...",
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            LamiButton(
              icon: LucideIcons.upload,
              label: "Upload",
              onPressed: _uploadManualSchema,
            ),
          ],
        ),
        Expanded(
          child: state.isLoading && state.availablePlugins.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(),
                  ),
                )
              : filteredAndGrouped.isEmpty
              ? Center(
                  child: ShopEmptyState(
                    isSearch: _searchController.text.isNotEmpty,
                    state: state,
                    onRetry: () =>
                        ref.read(schemaShopProvider.notifier).fetchPlugins(),
                  ),
                )
              : Scrollbar(
                  child: ShopPluginList(
                    items: filteredAndGrouped,
                    onInstall: _install,
                  ),
                ),
        ),
        if (state.error != null && filteredAndGrouped.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ],
    );
  }
}
