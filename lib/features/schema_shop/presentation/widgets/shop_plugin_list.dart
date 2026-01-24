import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/application_group_card.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/plugin_card.dart';

class ShopPluginList extends ConsumerWidget {
  final List<dynamic> items;
  final Function(PluginManifest, String) onInstall;

  const ShopPluginList({
    super.key,
    required this.items,
    required this.onInstall,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(schemaShopProvider);

    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) {
        final item = items[index];

        if (item is ApplicationGroup) {
          return ApplicationGroupCard(
            group: item,
            onInstall: onInstall,
            onRemove: (pluginId) {
              ref.read(schemaShopProvider.notifier).uninstallPlugin(pluginId);
            },
          );
        } else if (item is PluginManifest) {
          final isInstalled = state.installedPlugins.any(
            (p) => p.plugin.pluginID == item.plugin.pluginID,
          );

          return PluginCard(
            plugin: item,
            isInstalled: isInstalled,
            isInstalling: state.isLoading && state.activeSchema == null,
            onInstall: () {
              if (item.schemas.isEmpty) return;

              if (item.schemas.length == 1) {
                onInstall(item, item.schemas.first.id);
              } else {
                _showVersionPicker(context, item);
              }
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showVersionPicker(BuildContext context, PluginManifest item) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 100, 100),
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
        onInstall(item, schemaId);
      }
    });
  }
}
