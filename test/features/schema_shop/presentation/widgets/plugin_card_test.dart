import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import 'package:laminode_app/features/schema_shop/presentation/widgets/plugin_card.dart';

void main() {
  final tPlugin = PluginManifest(
    pluginType: 'sector',
    displayName: 'Test Plugin',
    description: 'Test Description',
    plugin: PluginInfo(
      pluginID: 'test_plugin',
      pluginVersion: '1.0.0',
      pluginAuthor: 'Author',
      publishedDate: '2023-01-01',
      sector: 'FDM',
    ),
    schemas: [],
  );

  testWidgets('should render plugin information correctly', (tester) async {
    // act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PluginCard(plugin: tPlugin, onInstall: () {}),
        ),
      ),
    );

    // assert
    expect(find.text('Test Plugin'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.textContaining('Author'), findsOneWidget);
  });

  testWidgets('should call onInstall when the button is pressed', (
    tester,
  ) async {
    // arrange
    bool pressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PluginCard(
            plugin: tPlugin,
            onInstall: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    // act
    await tester.tap(find.text('Install'));
    await tester.pump();

    // assert
    expect(pressed, true);
  });
}
