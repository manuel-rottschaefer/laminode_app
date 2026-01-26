import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';

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
  void updateLayers(any) {}
  @override
  void setApplication(any) {}
  @override
  Future<void> saveCurrentProfile() async {}
}

void main() {
  late ProviderContainer container;
  late MockGetLayersUseCase mockGetLayersUseCase;
  late MockAddLayerUseCase mockAddLayerUseCase;
  late MockRemoveLayerUseCase mockRemoveLayerUseCase;
  late MockUpdateLayerNameUseCase mockUpdateLayerNameUseCase;
  late MockLayerPanelRepository mockRepository;
  late FakeProfileManagerNotifier fakeProfileManagerNotifier;

  setUp(() {
    mockGetLayersUseCase = MockGetLayersUseCase();
    mockAddLayerUseCase = MockAddLayerUseCase();
    mockRemoveLayerUseCase = MockRemoveLayerUseCase();
    mockUpdateLayerNameUseCase = MockUpdateLayerNameUseCase();
    mockRepository = MockLayerPanelRepository();
    fakeProfileManagerNotifier = FakeProfileManagerNotifier();

    container = ProviderContainer(
      overrides: [
        getLayersUseCaseProvider.overrideWithValue(mockGetLayersUseCase),
        addLayerUseCaseProvider.overrideWithValue(mockAddLayerUseCase),
        removeLayerUseCaseProvider.overrideWithValue(mockRemoveLayerUseCase),
        updateLayerNameUseCaseProvider.overrideWithValue(
          mockUpdateLayerNameUseCase,
        ),
        layerPanelRepositoryProvider.overrideWithValue(mockRepository),
        profileManagerProvider.overrideWith(
          (ref) => fakeProfileManagerNotifier,
        ),
      ],
    );

    // Initial state setup
    when(() => mockGetLayersUseCase()).thenReturn([]);
    when(() => mockRepository.setLayers(any())).thenReturn(null);
  });

  tearDown(() {
    container.dispose();
  });

  test('initial state should be empty', () {
    final state = container.read(layerPanelProvider);
    expect(state.layers, []);
    expect(state.expandedIndex, isNull);
  });

  test('setExpandedIndex should update state', () {
    final notifier = container.read(layerPanelProvider.notifier);

    notifier.setExpandedIndex(5);
    expect(container.read(layerPanelProvider).expandedIndex, 5);

    // Toggle off
    notifier.setExpandedIndex(5);
    expect(container.read(layerPanelProvider).expandedIndex, isNull);

    // Toggle on different
    notifier.setExpandedIndex(3);
    expect(container.read(layerPanelProvider).expandedIndex, 3);
  });

  test('reorderLayers should update repository and state', () {
    const l1 = LamiLayerEntry(
      layerName: 'L1',
      parameters: [],
      layerAuthor: '',
      layerDescription: '',
    );
    const l2 = LamiLayerEntry(
      layerName: 'L2',
      parameters: [],
      layerAuthor: '',
      layerDescription: '',
    );

    when(() => mockGetLayersUseCase()).thenReturn([l1, l2]);
    final notifier = container.read(layerPanelProvider.notifier);

    // Simulate initial load which would have been empty.
    // We need to trigger a refresh to see the layers we just 'arranged'
    when(() => mockGetLayersUseCase()).thenReturn([l2, l1]); // After reorder

    notifier.reorderLayers(0, 2); // Move L1 to the end

    verify(
      () => mockRepository.setLayers(any(that: equals([l2, l1]))),
    ).called(1);
    expect(container.read(layerPanelProvider).layers, [l2, l1]);
  });

  test('moveLayerUp should move item and update repository', () {
    const l1 = LamiLayerEntry(
      layerName: 'L1',
      parameters: [],
      layerAuthor: '',
      layerDescription: '',
    );
    const l2 = LamiLayerEntry(
      layerName: 'L2',
      parameters: [],
      layerAuthor: '',
      layerDescription: '',
    );

    // 1. Setup UseCase to return initial layers
    when(() => mockGetLayersUseCase()).thenReturn([l1, l2]);

    // 2. Initialize notifier (this will call build() but profile is null initially)
    final notifier = container.read(layerPanelProvider.notifier);

    // 3. Set profile (this will trigger build() via ref.watch)
    final profile = ProfileEntity(
      name: 'Test',
      layers: [l1, l2],
      application: ProfileApplication.empty(),
    );
    fakeProfileManagerNotifier.setProfile(profile);

    // 4. Clear the call from build() sync
    clearInteractions(mockRepository);

    // 5. Setup UseCase for the refresh call after reorder
    when(() => mockGetLayersUseCase()).thenReturn([l2, l1]);

    notifier.moveLayerUp(1);

    verify(
      () => mockRepository.setLayers(any(that: equals([l2, l1]))),
    ).called(1);
    expect(container.read(layerPanelProvider).layers, [l2, l1]);
  });

  test('moveLayerDown should move item and update repository', () {
    const l1 = LamiLayerEntry(
      layerName: 'L1',
      parameters: [],
      layerAuthor: '',
      layerDescription: '',
    );
    const l2 = LamiLayerEntry(
      layerName: 'L2',
      parameters: [],
      layerAuthor: '',
      layerDescription: '',
    );

    when(() => mockGetLayersUseCase()).thenReturn([l1, l2]);
    final notifier = container.read(layerPanelProvider.notifier);

    final profile = ProfileEntity(
      name: 'Test',
      layers: [l1, l2],
      application: ProfileApplication.empty(),
    );
    fakeProfileManagerNotifier.setProfile(profile);

    clearInteractions(mockRepository);

    when(() => mockGetLayersUseCase()).thenReturn([l2, l1]);

    notifier.moveLayerDown(0);

    verify(
      () => mockRepository.setLayers(any(that: equals([l2, l1]))),
    ).called(1);
    expect(container.read(layerPanelProvider).layers, [l2, l1]);
  });

  test('setSearchQuery should update search query in state', () {
    final notifier = container.read(layerPanelProvider.notifier);

    notifier.setSearchQuery('test');
    expect(container.read(layerPanelProvider).searchQuery, 'test');

    notifier.setSearchQuery('');
    expect(container.read(layerPanelProvider).searchQuery, '');
  });
}
