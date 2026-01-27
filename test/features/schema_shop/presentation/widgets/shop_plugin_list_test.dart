import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/shop_plugin_list.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/plugin_card.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/application_group_card.dart';

void main() {
  final tPlugin = PluginManifest(
    displayName: 'Plugin',
    description: 'Desc',
    pluginType: 'sector',
    plugin: PluginInfo(
      pluginID: 'id',
      pluginVersion: '1.0',
      pluginAuthor: 'Author',
      publishedDate: 'date',
      sector: 'FDM',
    ),
    schemas: [],
  );

  final tGroup = ApplicationGroup(
    appName: 'App',
    vendor: 'Vendor',
    sector: 'FDM',
    appVersions: [],
  );

  testWidgets(
    'ShopPluginList should render PluginCard for PluginManifest items',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schemaShopProvider.overrideWith(
              (ref) => SchemaShopNotifierMock([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ShopPluginList(items: [tPlugin], onInstall: (p, s) {}),
            ),
          ),
        ),
      );

      expect(find.byType(PluginCard), findsOneWidget);
    },
  );

  testWidgets(
    'ShopPluginList should render ApplicationGroupCard for ApplicationGroup items',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schemaShopProvider.overrideWith(
              (ref) => SchemaShopNotifierMock([]),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ShopPluginList(items: [tGroup], onInstall: (p, s) {}),
            ),
          ),
        ),
      );

      expect(find.byType(ApplicationGroupCard), findsOneWidget);
    },
  );
}

class SchemaShopNotifierMock extends StateNotifier<SchemaShopState>
    implements SchemaShopNotifier {
  final List<PluginManifest> plugins;
  SchemaShopNotifierMock(this.plugins)
    : super(SchemaShopState(availablePlugins: plugins));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
