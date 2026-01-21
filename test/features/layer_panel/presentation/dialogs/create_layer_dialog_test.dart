import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/create_layer_dialog.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
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

  group('CreateLayerDialog', () {
    late MockLayerPanelRepository mockPanelRepo;
    late ProviderContainer container;

    setUp(() {
      mockPanelRepo = MockLayerPanelRepository();

      final List<CamCategoryEntry> categories = [
        CamCategoryEntry(
          categoryName: 'cat1',
          categoryTitle: 'Category 1',
          categoryColorName: 'blue',
        ),
        CamCategoryEntry(
          categoryName: 'cat2',
          categoryTitle: 'Category 2',
          categoryColorName: 'red',
        ),
      ];

      when(() => mockPanelRepo.addLayer(any())).thenAnswer((_) async {});
      when(() => mockPanelRepo.getLayers()).thenReturn([]);

      container = ProviderContainer(
        overrides: [
          layerPanelRepositoryProvider.overrideWithValue(mockPanelRepo),
          activeSchemaCategoriesProvider.overrideWithValue(categories),
        ],
      );
    });

    testWidgets('renders correctly and validates form', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CreateLayerDialog())),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Category 1'), findsOneWidget);
      expect(find.text('Category 2'), findsOneWidget);

      // Select a category to enable the create button
      await tester.tap(find.text('Category 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('creates layer and pops dialog', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: Scaffold(body: CreateLayerDialog())),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test Layer');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Category 1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      verify(
        () => mockPanelRepo.addLayer(
          any(
            that: isA<LamiLayerEntry>()
                .having((p0) => p0.layerName, 'layerName', 'Test Layer')
                .having((p0) => p0.layerCategory, 'layerCategory', 'cat1'),
          ),
        ),
      ).called(1);
    });
  });
}
