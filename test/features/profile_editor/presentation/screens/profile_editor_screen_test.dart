import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/profile_editor/presentation/screens/profile_editor_screen.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/widgets/layer_panel.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';
import 'package:laminode_app/features/evaluation/application/providers.dart';

import '../../../../mocks/mocks.dart';

class MockEvaluationEngine extends Mock implements EvaluationEngine {}

class FakeProfileManagerNotifier extends StateNotifier<ProfileManagerState>
    implements ProfileManagerNotifier {
  FakeProfileManagerNotifier() : super(ProfileManagerState());

  @override
  Future<void> createProfile(dynamic profile) async {
    state = state.copyWith(currentProfile: profile);
  }

  @override
  Future<void> loadProfile(dynamic path) async {}
  @override
  Future<void> setProfile(dynamic profile) async {
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

class MockSchemaShopNotifier extends StateNotifier<SchemaShopState>
    implements SchemaShopNotifier {
  MockSchemaShopNotifier() : super(SchemaShopState());

  @override
  Future<void> fetchPlugins() async {}
  @override
  Future<void> refreshInstalled() async {}
  @override
  Future<void> installPlugin(dynamic p1, dynamic p2) async {}
  @override
  Future<void> installManualSchema(dynamic file) async {}
  @override
  Future<void> uninstallPlugin(dynamic pluginId) async {}
  @override
  Future<void> loadSchema(dynamic schemaId) async {}
  @override
  void clearActiveSchema() {}
}

void main() {
  late FakeProfileManagerNotifier fakeProfileManagerNotifier;
  late MockGetLayersUseCase mockGetLayersUseCase;
  late MockLayerPanelRepository mockLayerRepo;
  late MockEvaluationEngine mockEvaluationEngine;

  setUp(() {
    fakeProfileManagerNotifier = FakeProfileManagerNotifier();
    mockGetLayersUseCase = MockGetLayersUseCase();
    mockLayerRepo = MockLayerPanelRepository();
    mockEvaluationEngine = MockEvaluationEngine();

    when(() => mockGetLayersUseCase()).thenReturn([]);
    when(() => mockLayerRepo.setLayers(any())).thenReturn(null);
    when(
      () => mockEvaluationEngine.evaluate(any(), any()),
    ).thenReturn('MockResult');
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        profileManagerProvider.overrideWith(
          (ref) => fakeProfileManagerNotifier,
        ),
        getLayersUseCaseProvider.overrideWith((ref) => mockGetLayersUseCase),
        layerPanelRepositoryProvider.overrideWithValue(mockLayerRepo),
        evaluationEngineProvider.overrideWithValue(mockEvaluationEngine),
      ],
      child: const MaterialApp(home: ProfileEditorScreen()),
    );
  }

  testWidgets('should show LayerPanel when a profile is created', (
    WidgetTester tester,
  ) async {
    // Set a large surface size to avoid overflows
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Initial state: no profile
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    // LayerPanel should NOT be in the tree (it's inside if (hasProfile))
    expect(find.byType(LayerPanel), findsNothing);

    // 2. Create/Set a profile
    final testProfile = ProfileEntity(
      name: 'Test Profile',
      application: ProfileApplication.empty(),
      layers: [],
    );

    await fakeProfileManagerNotifier.createProfile(testProfile);

    // 3. Re-pump and check
    await tester.pump();
    // Use pumpAndSettle if there are animations, but pump should be enough for visibility
    await tester.pumpAndSettle();

    expect(find.byType(LayerPanel), findsOneWidget);
  });
}
