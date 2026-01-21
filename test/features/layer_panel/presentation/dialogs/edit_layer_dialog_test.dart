import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/layer_management/presentation/providers/layer_management_provider.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/dialogs/edit_layer_dialog.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
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

  group('EditLayerDialog', () {
    late MockLayerPanelRepository mockPanelRepo;
    late MockLayerManagementRepository mockManagementRepo;
    late ProviderContainer container;
    final layerEntry = const LamiLayerEntry(
      layerName: 'Test Layer',
      parameters: [],
      layerAuthor: 'author',
      layerDescription: 'description',
    );

    setUp(() {
      mockPanelRepo = MockLayerPanelRepository();
      mockManagementRepo = MockLayerManagementRepository();

      // Mock the initial state of layers in the repository
      when(() => mockPanelRepo.getLayers()).thenReturn([layerEntry]);

      container = ProviderContainer(
        overrides: [
          layerPanelRepositoryProvider.overrideWithValue(mockPanelRepo),
          layerManagementRepositoryProvider.overrideWithValue(
            mockManagementRepo,
          ),
        ],
      );
    });

    testWidgets('renders correctly and validates form', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: EditLayerDialog(entry: layerEntry, index: 0)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Test Layer'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('saves changes and pops dialog', (tester) async {
      when(
        () => mockPanelRepo.updateLayer(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => mockManagementRepo.saveLayerToStorage(any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(body: EditLayerDialog(entry: layerEntry, index: 0)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'New Layer Name',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      verify(
        () => mockPanelRepo.updateLayer(
          0,
          any(
            that: isA<LamiLayerEntry>().having(
              (p0) => p0.layerName,
              'layerName',
              'New Layer Name',
            ),
          ),
        ),
      ).called(1);

      verify(
        () => mockManagementRepo.saveLayerToStorage(
          any(
            that: isA<LamiLayerEntry>().having(
              (p0) => p0.layerName,
              'layerName',
              'New Layer Name',
            ),
          ),
        ),
      ).called(1);
    });
  });
}
