import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/core/utils/version_utils.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';

final filteredAndGroupedPluginsProvider =
    Provider.family<List<dynamic>, String>((ref, query) {
      final state = ref.watch(schemaShopProvider);
      final plugins = state.availablePlugins;

      final filtered = plugins.where((p) {
        final lowerQuery = query.toLowerCase();
        return p.displayName.toLowerCase().contains(lowerQuery) ||
            p.description.toLowerCase().contains(lowerQuery) ||
            p.plugin.pluginAuthor.toLowerCase().contains(lowerQuery) ||
            (p.application?.vendor.toLowerCase().contains(lowerQuery) ??
                false) ||
            (p.application?.appName.toLowerCase().contains(lowerQuery) ??
                false);
      }).toList();

      final List<PluginManifest> sectors = filtered
          .where((p) => p.pluginType == 'sector')
          .toList();
      final List<PluginManifest> apps = filtered
          .where((p) => p.pluginType == 'application')
          .toList();

      final Map<String, List<PluginManifest>> groupedApps = {};
      for (final app in apps) {
        if (app.application == null) continue;
        final key = "${app.application!.appName}_${app.application!.vendor}";
        groupedApps.putIfAbsent(key, () => []).add(app);
      }

      final List<ApplicationGroup> appGroups = groupedApps.values.map((
        versions,
      ) {
        final Map<String, PluginManifest> latestByAppVer = {};
        for (final v in versions) {
          final appVer = v.application!.appVersion;
          if (!latestByAppVer.containsKey(appVer)) {
            latestByAppVer[appVer] = v;
          } else {
            if (compareVersions(
                  v.plugin.pluginVersion,
                  latestByAppVer[appVer]!.plugin.pluginVersion,
                ) >
                0) {
              latestByAppVer[appVer] = v;
            }
          }
        }

        final sortedVersions = latestByAppVer.values.toList()
          ..sort(
            (a, b) => compareVersions(
              b.application!.appVersion,
              a.application!.appVersion,
            ),
          );

        return ApplicationGroup(
          appName: sortedVersions.first.application!.appName,
          vendor: sortedVersions.first.application!.vendor,
          sector: sortedVersions.first.application!.sector,
          appVersions: sortedVersions,
        );
      }).toList();

      return [...appGroups, ...sectors];
    });
