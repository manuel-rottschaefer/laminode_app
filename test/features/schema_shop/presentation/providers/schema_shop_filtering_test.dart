import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';

void main() {
  group('filteredAndGroupedPluginsProvider', () {
    final tPlugin1 = PluginManifest(
      displayName: 'Cura Plugin',
      description: 'The Cura plugin',
      pluginType: 'application',
      application: ApplicationInfo(
        appName: 'Cura',
        appVersion: '5.0',
        vendor: 'Ultimaker',
        website: 'https://ultimaker.com',
        sector: 'FDM',
      ),
      plugin: PluginInfo(
        pluginID: 'cura_plugin',
        pluginVersion: '1.0.0',
        pluginAuthor: 'Ultimaker',
        publishedDate: '2026-01-27',
        sector: 'FDM',
      ),
      schemas: [],
    );

    final tPlugin2 = PluginManifest(
      displayName: 'Prusa Plugin',
      description: 'The Prusa plugin',
      pluginType: 'application',
      application: ApplicationInfo(
        appName: 'PrusaSlicer',
        appVersion: '2.5',
        vendor: 'Prusa',
        website: 'https://prusa3d.com',
        sector: 'FDM',
      ),
      plugin: PluginInfo(
        pluginID: 'prusa_plugin',
        pluginVersion: '1.2.0',
        pluginAuthor: 'Prusa',
        publishedDate: '2026-01-27',
        sector: 'FDM',
      ),
      schemas: [],
    );

    final tSector = PluginManifest(
      displayName: 'FDM Sector',
      description: 'FDM related schemas',
      pluginType: 'sector',
      plugin: PluginInfo(
        pluginID: 'fdm_sector',
        pluginVersion: '1.0.0',
        pluginAuthor: 'Community',
        publishedDate: '2026-01-27',
        sector: 'FDM',
      ),
      schemas: [],
    );

    test('should filter plugins based on query string', () {
      final container = ProviderContainer(
        overrides: [
          schemaShopProvider.overrideWith(
            (ref) => SchemaShopNotifierMock([tPlugin1, tPlugin2, tSector]),
          ),
        ],
      );

      final filtered = container.read(
        filteredAndGroupedPluginsProvider('Cura'),
      );

      expect(filtered.length, 1);
      expect((filtered.first as ApplicationGroup).appName, 'Cura');
    });

    test('should group multiple versions of the same application', () {
      final tPlugin1v2 = PluginManifest(
        displayName: 'Cura Plugin v2',
        description: 'The Cura plugin newer version',
        pluginType: 'application',
        application: ApplicationInfo(
          appName: 'Cura',
          appVersion: '5.1', // Different app version
          vendor: 'Ultimaker',
          website: 'https://ultimaker.com',
          sector: 'FDM',
        ),
        plugin: PluginInfo(
          pluginID: 'cura_plugin_v2',
          pluginVersion: '1.1.0',
          pluginAuthor: 'Ultimaker',
          publishedDate: '2026-01-27',
          sector: 'FDM',
        ),
        schemas: [],
      );

      final container = ProviderContainer(
        overrides: [
          schemaShopProvider.overrideWith(
            (ref) => SchemaShopNotifierMock([tPlugin1, tPlugin1v2]),
          ),
        ],
      );

      final filtered = container.read(filteredAndGroupedPluginsProvider(''));

      expect(filtered.length, 1);
      final group = filtered.first as ApplicationGroup;
      expect(group.appVersions.length, 2);
    });
  });
}

class SchemaShopNotifierMock extends StateNotifier<SchemaShopState>
    implements SchemaShopNotifier {
  final List<PluginManifest> plugins;
  SchemaShopNotifierMock(this.plugins)
    : super(SchemaShopState(availablePlugins: plugins));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
