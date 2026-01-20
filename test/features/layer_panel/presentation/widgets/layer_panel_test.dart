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

import '../../../../mocks/mocks.dart';

class FakeProfileManagerNotifier extends StateNotifier<ProfileManagerState>
    implements ProfileManagerNotifier {
  FakeProfileManagerNotifier() : super(ProfileManagerState());

  @override
  Future<void> createProfile(any) async {}
  @override
  Future<void> loadProfile(any) async {}
  @override
  void setProfile(any) {
    state = state.copyWith(currentProfile: any, clearProfile: any == null);
  }

  @override
  void setSchema(any) {}
  @override
  void updateProfileName(any) {}
  @override
  void setApplication(any) {}
}

void main() {
  late MockGetLayersUseCase mockGetLayersUseCase;
  late MockLayerPanelRepository mockRepository;
  late FakeProfileManagerNotifier fakeProfileManagerNotifier;

  setUp(() {
    mockGetLayersUseCase = MockGetLayersUseCase();
    mockRepository = MockLayerPanelRepository();
    fakeProfileManagerNotifier = FakeProfileManagerNotifier();

    registerFallbackValue(
      const LamiLayerEntry(
        layerName: '',
        parameters: [],
        layerAuthor: '',
        layerDescription: '',
      ),
    );

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
