import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import 'package:laminode_app/core/presentation/widgets/lami_box.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/layer_management/presentation/providers/layer_management_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

class FindLayersDialog extends ConsumerWidget {
  const FindLayersDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storedLayersAsync = ref.watch(storedLayersProvider);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: LamiButton(
                icon: LucideIcons.filePlus,
                label: "Import .lmdl",
                onPressed: () async {
                  // Implement file picker and import
                },
              ),
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
              if (layers.isEmpty) {
                return const Center(child: Text("No stored layers found."));
              }
              return ListView.separated(
                itemCount: layers.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) {
                  final layer = layers[index];
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
