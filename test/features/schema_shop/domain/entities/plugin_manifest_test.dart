import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';

void main() {
  group('PluginManifest', () {
    test('should be initialized correctly', () {
      final manifest = PluginManifest(
        displayName: 'Test',
        description: 'Desc',
        pluginType: 'application',
        plugin: PluginInfo(
          pluginID: 'id',
          pluginVersion: '1.0',
          pluginAuthor: 'Author',
          publishedDate: 'date',
          sector: 'FDM',
        ),
        schemas: [],
      );

      expect(manifest.displayName, 'Test');
    });
  });
}
