import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/schema_selection_dialog.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';

import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import '../../../../mocks/mocks.dart';

void main() {
  group('SchemaSelectionDialog', () {
    testWidgets('renders schemas and handles selection', (tester) async {
      final schemas = [
        SchemaRef(id: '1', version: '1.0.0', releaseDate: '2023-01-01'),
        SchemaRef(id: '2', version: '2.0.0', releaseDate: '2023-02-01'),
      ];
      final plugin = PluginManifest(
        pluginType: 'application',
        displayName: 'Test App',
        description: 'Test Desc',
        plugin: PluginInfo(
          pluginID: 'app1',
          pluginVersion: '1.0.0',
          pluginAuthor: 'Me',
          publishedDate: '2023-01-01',
          sector: 'FDM',
        ),
        schemas: schemas,
      );

      ProfileSchemaManifest? selectedManifest;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            installedSchemasForAppProvider('app1').overrideWithValue(schemas),
            schemaShopProvider.overrideWith((ref) {
              final notifier = MockSchemaShopNotifier();
              notifier.state = SchemaShopState(installedPlugins: [plugin]);
              return notifier;
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SchemaSelectionDialog(
                applicationId: 'app1',
                onSchemaSelected: (manifest) {
                  selectedManifest = manifest;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Version: 1.0.0'), findsOneWidget);
      expect(find.text('Version: 2.0.0'), findsOneWidget);

      await tester.tap(find.text('Version: 1.0.0'));
      await tester.pumpAndSettle();

      expect(selectedManifest?.id, '1');
    });
  });
}
