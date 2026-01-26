import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_panel.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/core/presentation/widgets/lami_action_widgets.dart';
import '../../../../helpers/test_models.dart';

import '../../../../mocks/mocks.dart';

class FakeProfileManagerNotifier extends StateNotifier<ProfileManagerState>
    implements ProfileManagerNotifier {
  FakeProfileManagerNotifier() : super(ProfileManagerState());

  @override
  Future<void> createProfile(dynamic profile) async {}
  @override
  Future<void> loadProfile(dynamic path) async {}
  @override
  void setProfile(dynamic profile) {
    state = state.copyWith(
      currentProfile: profile,
      clearProfile: profile == null,
    );
  }

  @override
  void setSchema(dynamic schemaId) {}
  @override
  void updateProfileName(dynamic name) {}
  @override
  void updateLayers(dynamic layers) {}
  @override
  void setApplication(dynamic application) {}
  @override
  Future<void> saveCurrentProfile() async {}
}

void main() {
  late MockGetLayersUseCase mockGetLayersUseCase;
  late MockLayerPanelRepository mockRepository;
  late FakeProfileManagerNotifier fakeProfileManagerNotifier;

  setUpAll(() {
    registerFallbackValue(
      const LamiLayerEntry(
        layerName: '',
        parameters: [],
        layerAuthor: '',
        layerDescription: '',
      ),
    );
  });

  setUp(() {
    mockGetLayersUseCase = MockGetLayersUseCase();
    mockRepository = MockLayerPanelRepository();
    fakeProfileManagerNotifier = FakeProfileManagerNotifier();

    when(() => mockRepository.setLayers(any())).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        getLayersUseCaseProvider.overrideWith((ref) => mockGetLayersUseCase),
        layerPanelRepositoryProvider.overrideWithValue(mockRepository),
        profileManagerProvider.overrideWith(
          (ref) => fakeProfileManagerNotifier,
        ),
      ],
      child: const MaterialApp(home: Scaffold(body: LayerPanel())),
    );
  }

  testWidgets('should expand a layer when tapped', (WidgetTester tester) async {
    final layers = [
      const LamiLayerEntry(
        layerName: 'Test Layer',
        parameters: [],
        layerAuthor: '',
        layerDescription: '',
      ),
    ];

    when(() => mockGetLayersUseCase()).thenReturn(layers);
    fakeProfileManagerNotifier.setProfile(
      ProfileEntity(
        name: 'Test',
        layers: layers,
        application: ProfileApplication.empty(),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Verify initial state: not expanded (no edit icon visible yet)
    expect(find.byIcon(Icons.edit_rounded), findsNothing);

    // Tap to expand
    await tester.tap(find.text('Test Layer'));
    await tester.pumpAndSettle();

    // Verify expanded state
    expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
  });

  testWidgets('should open create layer dialog when add button is clicked', (
    WidgetTester tester,
  ) async {
    when(() => mockGetLayersUseCase()).thenReturn([]);
    fakeProfileManagerNotifier.setProfile(
      ProfileEntity(
        name: 'Test',
        layers: [],
        application: ProfileApplication.empty(),
        schema: TestModels
            .tProfileSchemaManifest, // Must have schema to enable button
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // Find and tap "Create Layer" button
    await tester.tap(find.text('Create Layer'));
    await tester.pumpAndSettle();

    // Verify dialog appeared
    expect(find.text('New Profile Layer'), findsOneWidget);
  });

  testWidgets('should filter layers based on search query', (
    WidgetTester tester,
  ) async {
    final layers = [
      const LamiLayerEntry(
        layerName: 'Base Layer',
        parameters: [],
        layerAuthor: '',
        layerDescription: '',
      ),
      const LamiLayerEntry(
        layerName: 'Detail Layer',
        parameters: [],
        layerAuthor: '',
        layerDescription: '',
      ),
    ];

    when(() => mockGetLayersUseCase()).thenReturn(layers);

    // Set a profile to show the list
    fakeProfileManagerNotifier.setProfile(
      ProfileEntity(
        name: 'Test',
        layers: layers,
        application: ProfileApplication.empty(),
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Base Layer'), findsOneWidget);
    expect(find.text('Detail Layer'), findsOneWidget);

    // Toggle search
    await tester.tap(find.byType(LamiToggleIcon));
    await tester.pumpAndSettle();

    // Enter search text
    await tester.enterText(find.byType(TextField), 'base');
    await tester.pumpAndSettle();

    expect(find.text('Base Layer'), findsOneWidget);
    expect(find.text('Detail Layer'), findsNothing);

    // Filter with no results
    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pumpAndSettle();

    expect(find.text('No layers found for your search'), findsOneWidget);

    // Clear search
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();

    expect(find.text('Base Layer'), findsOneWidget);
    expect(find.text('Detail Layer'), findsOneWidget);
  });
}
