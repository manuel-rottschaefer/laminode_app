import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/plugin_card.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/application_group_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(schemaShopProvider);
    final theme = Theme.of(context);

    final filteredAndGrouped = ref.watch(filteredAndGroupedPluginsProvider(_searchController.text));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
            LamiButton(icon: LucideIcons.upload, label: "Upload", onPressed: _uploadManualSchema),
          ],
        ),
        const SizedBox(height: AppSpacing.l),
        Flexible(
          child: state.isLoading && state.availablePlugins.isEmpty
              ? const Center(
                  child: Padding(padding: EdgeInsets.all(AppSpacing.xl), child: CircularProgressIndicator()),
                )
              : filteredAndGrouped.isEmpty
              ? Center(
                  child: _ShopEmptyState(
                    isSearch: _searchController.text.isNotEmpty,
                    state: state,
                    onRetry: () => ref.read(schemaShopProvider.notifier).fetchPlugins(),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: filteredAndGrouped.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
                  itemBuilder: (context, index) {
                    final item = filteredAndGrouped[index];

                    if (item is ApplicationGroup) {
                      return ApplicationGroupCard(
                        group: item,
                        onInstall: _install,
                        onRemove: (pluginId) {
                          ref.read(schemaShopProvider.notifier).uninstallPlugin(pluginId);
                        },
                      );
                    } else if (item is PluginManifest) {
                      final isInstalled = state.installedPlugins.any((p) => p.plugin.pluginID == item.plugin.pluginID);

                      return PluginCard(
                        plugin: item,
                        isInstalled: isInstalled,
                        isInstalling: state.isLoading && state.activeSchema == null,
                        onInstall: () {
                          if (item.schemas.isEmpty) return;

                          if (item.schemas.length == 1) {
                            _install(item, item.schemas.first.id);
                          } else {
                            // Show simple version picker
                            showMenu(
                              context: context,
                              position: const RelativeRect.fromLTRB(
                                100,
                                100,
                                100,
                                100,
                              ), // Better positioning would be nice
                              items: item.schemas
                                  .map(
                                    (s) => PopupMenuItem(
                                      value: s.id,
                                      child: Text('Version: ${s.version} (${s.releaseDate})'),
                                    ),
                                  )
                                  .toList(),
                            ).then((schemaId) {
                              if (schemaId != null) {
                                _install(item, schemaId);
                              }
                            });
                          }
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
        ),
        if (state.error != null && filteredAndGrouped.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.m),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(
              state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.l),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LamiButton(icon: LucideIcons.logOut, label: "Quit", onPressed: () => Navigator.of(context).pop()),
            LamiButton(icon: LucideIcons.folder, label: "Show Directory", onPressed: _showDirectory),
          ],
        ),
      ],
    );
  }

  Future<void> _showDirectory() async {
    final dir = await getApplicationSupportDirectory();
    await Process.run('xdg-open', [dir.path]);
  }

  Future<void> _uploadManualSchema() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      await ref.read(schemaShopProvider.notifier).installManualSchema(file);
    }
  }

  void _install(PluginManifest plugin, String schemaId) {
    ref.read(schemaShopProvider.notifier).installPlugin(plugin, schemaId).then((_) {
      if (mounted && ref.read(schemaShopProvider).error == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Successfully installed ${plugin.displayName} - $schemaId')));
      }
    });
  }
}

class _ShopEmptyState extends StatelessWidget {
  final bool isSearch;
  final SchemaShopState state;
  final VoidCallback onRetry;

  const _ShopEmptyState({required this.isSearch, required this.state, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConnectionError = state.hasConnectionError;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isConnectionError ? LucideIcons.wifiOff : (isSearch ? LucideIcons.search : LucideIcons.packageOpen),
              size: 32,
              color: isConnectionError
                  ? theme.colorScheme.error.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              isConnectionError
                  ? "Unable to connect to LamiNode"
                  : (isSearch ? "No matching plugins found" : "No plugins available yet"),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              isConnectionError
                  ? "Please check your backend connection or internet access."
                  : (isSearch
                        ? "Try adjusting your search terms or sector filters."
                        : "The plugin store is currently empty. Check back later!"),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (state.hasError && !isConnectionError) ...[
              const SizedBox(height: AppSpacing.m),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ],
            if (isConnectionError) ...[
              const SizedBox(height: AppSpacing.l),
              LamiButton(icon: LucideIcons.refreshCw, label: "Try Again", onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
