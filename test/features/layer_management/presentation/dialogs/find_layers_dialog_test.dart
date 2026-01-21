import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_management/presentation/dialogs/find_layers_dialog.dart';
import 'package:laminode_app/features/layer_management/presentation/providers/layer_management_provider.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const LamiLayerEntry(
        layerName: 'fallback',
        parameters: [],
        layerAuthor: 'author',
        layerDescription: 'description',
      ),
    );
  });
  group('FindLayersDialog', () {
    late MockLayerManagementRepository mockManagementRepo;
    late MockLayerPanelRepository mockPanelRepo;
    late ProviderContainer container;

    setUp(() {
      mockManagementRepo = MockLayerManagementRepository();
      mockPanelRepo = MockLayerPanelRepository();

      when(() => mockManagementRepo.getStoredLayers()).thenAnswer(
        (_) async => [
          const LamiLayerEntry(
            layerName: 'Layer 1',
            parameters: [],
            layerAuthor: 'author',
            layerDescription: 'description',
            layerCategory: 'Category 1',
          ),
          const LamiLayerEntry(
            layerName: 'Layer 2',
            parameters: [],
            layerAuthor: 'author',
            layerDescription: 'description',
            layerCategory: 'Category 2',
          ),
        ],
      );

      when(() => mockPanelRepo.getLayers()).thenReturn([]);

      container = ProviderContainer(
        overrides: [
          layerManagementRepositoryProvider.overrideWithValue(
            mockManagementRepo,
          ),
          // Override the repository provider, not the notifier
          layerPanelRepositoryProvider.overrideWithValue(mockPanelRepo),
        ],
      );
    });

    testWidgets('renders correctly and filters layers', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: FindLayersDialog())),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Installed Layers'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('Layer 1'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('Layer 2'),
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField), 'Layer 1');
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(ListView),
          matching: find.text('Layer 1'),
        ),
        findsOneWidget,
      );
      expect(find.text('Layer 2'), findsNothing);
    });

    testWidgets('add layer button works', (tester) async {
      when(() => mockPanelRepo.addLayer(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: FindLayersDialog())),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(LucideIcons.plus).first);
      await tester.pumpAndSettle();

      verify(
        () => mockPanelRepo.addLayer(
          any(
            that: isA<LamiLayerEntry>().having(
              (p0) => p0.layerName,
              'layerName',
              'Layer 1',
            ),
          ),
        ),
      ).called(1);
    });
  });
}
