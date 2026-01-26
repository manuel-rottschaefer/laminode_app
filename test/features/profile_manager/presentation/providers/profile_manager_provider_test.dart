import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/plugin_manifest.dart';
import '../../../../helpers/test_models.dart';
import '../../../../mocks/mocks.dart';

class FakeSchemaShopNotifier extends StateNotifier<SchemaShopState>
    implements SchemaShopNotifier {
  FakeSchemaShopNotifier(super.state);

  String? lastLoadedSchemaId;
  bool clearActiveSchemaCalled = false;

  @override
  Future<void> fetchPlugins() async {}
  @override
  Future<void> refreshInstalled() async {}
  @override
  Future<void> installPlugin(any, any2) async {}
  @override
  Future<void> installManualSchema(any) async {}
  @override
  Future<void> uninstallPlugin(any) async {}
  @override
  Future<void> loadSchema(dynamic schemaId) async {
    lastLoadedSchemaId = schemaId;
  }

  @override
  void clearActiveSchema() {
    clearActiveSchemaCalled = true;
  }
}

void main() {
  late MockProfileRepository mockRepository;
  late MockSchemaShopRepository mockSchemaShopRepository;
  late FakeSchemaShopNotifier fakeSchemaShopNotifier;
  late ProviderContainer container;

  setup({List<String> installedIds = const []}) {
    mockRepository = MockProfileRepository();
    mockSchemaShopRepository = MockSchemaShopRepository();
    fakeSchemaShopNotifier = FakeSchemaShopNotifier(
      SchemaShopState(installedSchemaIds: installedIds),
    );

    // Default mock behavior for repository used in loadProfile verification
    when(
      () => mockSchemaShopRepository.getInstalledPlugins(),
    ).thenAnswer((_) async => []);

    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(mockRepository),
        schemaShopRepositoryProvider.overrideWithValue(
          mockSchemaShopRepository,
        ),
        schemaShopProvider.overrideWith((ref) => fakeSchemaShopNotifier),
      ],
    );
  }

  group('ProfileManagerNotifier', () {
    const application = ProfileApplication(
      id: 'test-id',
      name: 'Test App',
      vendor: 'Test Vendor',
      version: '1.0.0',
    );
    const tProfile = ProfileEntity(
      name: 'Test Profile',
      application: application,
      path: 'test.lmdp',
    );

    test('initial state should be empty', () {
      setup();
      final state = container.read(profileManagerProvider);
      expect(state.currentProfile, isNull);
      expect(state.isLoading, isFalse);
    });

    test('createProfile should update state and call repository', () async {
      setup();
      when(() => mockRepository.saveProfile(any())).thenAnswer((_) async {});

      await container
          .read(profileManagerProvider.notifier)
          .createProfile(tProfile);

      final state = container.read(profileManagerProvider);
      expect(state.currentProfile, tProfile);
      expect(state.isLoading, isFalse);
      verify(() => mockRepository.saveProfile(tProfile)).called(1);
    });

    test('loadProfile should update state and call repository', () async {
      setup();
      when(
        () => mockRepository.loadProfile(any()),
      ).thenAnswer((_) async => tProfile);

      await container
          .read(profileManagerProvider.notifier)
          .loadProfile('test.lmdp');

      final state = container.read(profileManagerProvider);
      expect(state.currentProfile, tProfile);
      expect(state.isLoading, isFalse);
      verify(() => mockRepository.loadProfile('test.lmdp')).called(1);
    });

    test(
      'loadProfile should throw SchemaNotFoundException when schema is missing',
      () async {
        const pWithSchema = ProfileEntity(
          name: 'Test',
          application: application,
          schema: TestModels.tProfileSchemaManifest,
        );
        setup();

        when(
          () => mockSchemaShopRepository.getInstalledPlugins(),
        ).thenAnswer((_) async => []); // No plugins installed

        when(
          () => mockRepository.loadProfile(any()),
        ).thenAnswer((_) async => pWithSchema);

        await expectLater(
          container
              .read(profileManagerProvider.notifier)
              .loadProfile('test.lmdp'),
          throwsA(isA<SchemaNotFoundException>()),
        );

        final state = container.read(profileManagerProvider);
        expect(state.currentProfile, isNull);
      },
    );

    test('setProfile(null) should clear current profile', () {
      setup();
      final notifier = container.read(profileManagerProvider.notifier);

      notifier.setProfile(tProfile);
      expect(container.read(profileManagerProvider).currentProfile, tProfile);

      notifier.setProfile(null);
      expect(container.read(profileManagerProvider).currentProfile, isNull);
    });

    test('setSchema should update current profile and trigger schema load', () {
      setup();
      final notifier = container.read(profileManagerProvider.notifier);

      notifier.setProfile(tProfile);
      notifier.setSchema(TestModels.tProfileSchemaManifest);

      expect(
        container.read(profileManagerProvider).currentProfile?.schema,
        TestModels.tProfileSchemaManifest,
      );
      expect(
        fakeSchemaShopNotifier.lastLoadedSchemaId,
        TestModels.tProfileSchemaManifest.id,
      );
    });

    test(
      'loadProfile should verify manifest and trigger schema load',
      () async {
        setup();
        final manifest = PluginManifest(
          pluginType: TestModels.tProfileSchemaManifest.type,
          displayName: TestModels.tProfileSchemaManifest.targetAppName,
          description: 'Test Description',
          plugin: PluginInfo(
            pluginID: 'test-plugin',
            pluginVersion: TestModels.tProfileSchemaManifest.version,
            pluginAuthor: 'Author',
            publishedDate: TestModels.tProfileSchemaManifest.updated,
            sector: 'FDM',
          ),
          schemas: [
            SchemaRef(
              id: TestModels.tProfileSchemaManifest.id,
              version: TestModels.tProfileSchemaManifest.version,
              releaseDate: TestModels.tProfileSchemaManifest.updated,
            ),
          ],
        );

        when(
          () => mockSchemaShopRepository.getInstalledPlugins(),
        ).thenAnswer((_) async => [manifest]);

        final pWithSchema = tProfile.copyWith(
          schema: TestModels.tProfileSchemaManifest,
        );
        when(
          () => mockRepository.loadProfile(any()),
        ).thenAnswer((_) async => pWithSchema);

        await container
            .read(profileManagerProvider.notifier)
            .loadProfile('test.lmdp');

        expect(
          container.read(profileManagerProvider).currentProfile,
          pWithSchema,
        );
        expect(
          fakeSchemaShopNotifier.lastLoadedSchemaId,
          TestModels.tProfileSchemaManifest.id,
        );
      },
    );

    test('updateProfileName should update current profile name', () {
      setup();
      final notifier = container.read(profileManagerProvider.notifier);

      notifier.setProfile(tProfile);
      notifier.updateProfileName('Updated Name');

      expect(
        container.read(profileManagerProvider).currentProfile?.name,
        'Updated Name',
      );
    });
  });

  setUpAll(() {
    registerFallbackValue(
      const ProfileEntity(
        name: '',
        application: ProfileApplication(
          id: '',
          name: '',
          vendor: '',
          version: '',
        ),
      ),
    );
  });
}
