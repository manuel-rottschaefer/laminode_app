import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_management/presentation/providers/layer_management_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FindLayersDialog extends ConsumerStatefulWidget {
  const FindLayersDialog({super.key});

  @override
  ConsumerState<FindLayersDialog> createState() => _FindLayersDialogState();
}

class _FindLayersDialogState extends ConsumerState<FindLayersDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storedLayersAsync = ref.watch(storedLayersProvider);
    final managementState = ref.watch(layerManagementProvider);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: LamiSearch(
                controller: _searchController,
                hintText: "Search stored layers...",
                onChanged: (val) => ref
                    .read(layerManagementProvider.notifier)
                    .setSearchQuery(val),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            LamiButton(
              icon: LucideIcons.filePlus,
              label: "Import",
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['lmdl'],
                );
                if (result != null && result.files.single.path != null) {
                  await ref
                      .read(layerManagementProvider.notifier)
                      .importLayer(result.files.single.path!);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Text("Installed Layers", style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.s),
        SizedBox(
          height: 300,
          child: storedLayersAsync.when(
            data: (layers) {
              final filteredLayers = layers.where((l) {
                final query = managementState.searchQuery.toLowerCase();
                if (query.isEmpty) return true;
                return l.layerName.toLowerCase().contains(query) ||
                    (l.layerCategory?.toLowerCase().contains(query) ?? false);
              }).toList();

              if (filteredLayers.isEmpty) {
                return Center(
                  child: Text(
                    managementState.searchQuery.isEmpty
                        ? "No stored layers found."
                        : "No layers match your search.",
                  ),
                );
              }

              return ListView.separated(
                itemCount: filteredLayers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final layer = filteredLayers[index];
                  return LamiBox(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                layer.layerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (layer.layerCategory != null)
                                Text(
                                  layer.layerCategory!,
                                  style: theme.textTheme.labelSmall,
                                ),
                            ],
                          ),
                        ),
                        LamiIcon(
                          icon: LucideIcons.plus,
                          onPressed: () {
                            ref
                                .read(layerPanelProvider.notifier)
                                .addLayer(
                                  name: layer.layerName,
                                  description: layer.layerDescription,
                                  category: layer.layerCategory ?? 'Default',
                                );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text("Error: $err")),
          ),
        ),
      ],
    );
  }
}
