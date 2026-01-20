import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import '../../../../mocks/mocks.dart';

class FakeSchemaShopNotifier extends StateNotifier<SchemaShopState>
    implements SchemaShopNotifier {
  FakeSchemaShopNotifier(super.state);
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
  Future<void> loadSchema(any) async {}
  @override
  void clearActiveSchema() {}
}

void main() {
  late MockProfileRepository mockRepository;
  late FakeSchemaShopNotifier fakeSchemaShopNotifier;
  late ProviderContainer container;

  setup({List<String> installedIds = const []}) {
    mockRepository = MockProfileRepository();
    fakeSchemaShopNotifier = FakeSchemaShopNotifier(
      SchemaShopState(installedSchemaIds: installedIds),
    );

    container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(mockRepository),
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
          schemaId: 'missing-schema',
        );
        setup(installedIds: ['other-schema']);

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

    test('setSchema should update current profile schemaId', () {
      setup();
      final notifier = container.read(profileManagerProvider.notifier);

      notifier.setProfile(tProfile);
      notifier.setSchema('new-schema');

      expect(
        container.read(profileManagerProvider).currentProfile?.schemaId,
        'new-schema',
      );
    });

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
