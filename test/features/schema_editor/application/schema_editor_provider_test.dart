import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_provider.dart';
import 'package:laminode_app/features/schema_shop/domain/repositories/schema_shop_repository.dart';
import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';
import 'package:laminode_app/features/profile_manager/domain/repositories/profile_repository.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';

class MockSchemaShopRepository extends Mock implements SchemaShopRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockSchemaShopRepository mockSchemaRepo;
  late MockProfileRepository mockProfileRepo;
  late ProviderContainer container;

  setUp(() {
    mockSchemaRepo = MockSchemaShopRepository();
    mockProfileRepo = MockProfileRepository();

    container = ProviderContainer(
      overrides: [
        schemaShopRepositoryProvider.overrideWithValue(mockSchemaRepo),
        profileRepositoryProvider.overrideWithValue(mockProfileRepo),
      ],
    );

    // Default stubs
    when(
      () => mockSchemaRepo.applicationExists(any()),
    ).thenAnswer((_) async => true);
    when(
      () => mockSchemaRepo.schemaExists(any()),
    ).thenAnswer((_) async => false);
    when(
      () => mockSchemaRepo.getInstalledSchemaIds(),
    ).thenAnswer((_) async => []);
    when(
      () => mockSchemaRepo.getInstalledPlugins(),
    ).thenAnswer((_) async => []);
    when(
      () => mockSchemaRepo.getAvailablePlugins(),
    ).thenAnswer((_) async => []);
  });

  tearDown(() {
    container.dispose();
  });

  group('SchemaEditorNotifier', () {
    test('initial state is correct', () {
      final state = container.read(schemaEditorProvider);
      expect(state.schema.schemaName, 'New Schema');
      expect(state.manifest.schemaVersion, '1.0.0');
      expect(state.appExists, false);
      expect(state.versionExists, false);
    });

    test('loadSchema updates state and triggers validation', () async {
      final tSchema = CamSchemaEntry(
        schemaName: 'Loaded Schema',
        categories: [],
        availableParameters: [],
      );
      final tManifest = SchemaManifest(
        schemaType: 'application',
        schemaVersion: '2.0.0',
        schemaAuthors: [],
        lastUpdated: '',
        targetAppName: 'Target App',
      );

      when(
        () => mockSchemaRepo.applicationExists('Target App'),
      ).thenAnswer((_) async => true);
      when(
        () => mockSchemaRepo.schemaExists('2.0.0'),
      ).thenAnswer((_) async => false);

      container
          .read(schemaEditorProvider.notifier)
          .loadSchema(tSchema, tManifest);

      expect(
        container.read(schemaEditorProvider).schema.schemaName,
        'Loaded Schema',
      );

      // Wait for validation
      await Future.delayed(Duration.zero);

      expect(container.read(schemaEditorProvider).appExists, true);
      expect(container.read(schemaEditorProvider).versionExists, false);
      expect(container.read(schemaEditorProvider).canSave, true);
    });

    test('updateManifest triggers validation', () async {
      when(
        () => mockSchemaRepo.applicationExists('New App'),
      ).thenAnswer((_) async => false);

      container
          .read(schemaEditorProvider.notifier)
          .updateManifest(targetAppName: 'New App');

      // Wait for validation
      await Future.delayed(Duration.zero);

      expect(container.read(schemaEditorProvider).appExists, false);
      expect(container.read(schemaEditorProvider).canSave, false);
    });

    test('saveSchema calls repository and invalidates shop provider', () async {
      // Setup valid state
      container
          .read(schemaEditorProvider.notifier)
          .updateManifest(
            targetAppName: 'Installed App',
            schemaVersion: '1.2.3',
          );

      when(
        () => mockSchemaRepo.applicationExists('Installed App'),
      ).thenAnswer((_) async => true);
      when(
        () => mockSchemaRepo.schemaExists('1.2.3'),
      ).thenAnswer((_) async => false);
      when(
        () => mockSchemaRepo.saveSchema(any(), any(), any(), any()),
      ).thenAnswer((_) async => {});

      // Wait for validation
      await Future.delayed(Duration.zero);

      await container.read(schemaEditorProvider.notifier).saveSchema();

      verify(
        () => mockSchemaRepo.saveSchema('Installed App', '1.2.3', any(), any()),
      ).called(1);
    });

    test('saveAndUseSchema saves and updates profile', () async {
      const application = ProfileApplication(
        id: 'app',
        name: 'App',
        vendor: 'V',
        version: '1',
      );
      final profile = ProfileEntity(
        name: 'Test Profile',
        layers: [],
        application: application,
      );
      container.read(profileManagerProvider.notifier).setProfile(profile);

      container
          .read(schemaEditorProvider.notifier)
          .updateManifest(
            targetAppName: 'Installed App',
            schemaVersion: '1.2.3',
          );

      when(
        () => mockSchemaRepo.applicationExists('Installed App'),
      ).thenAnswer((_) async => true);
      when(
        () => mockSchemaRepo.schemaExists('1.2.3'),
      ).thenAnswer((_) async => false);
      when(
        () => mockSchemaRepo.saveSchema(any(), any(), any(), any()),
      ).thenAnswer((_) async => {});

      // Wait for validation
      await Future.delayed(Duration.zero);

      await container.read(schemaEditorProvider.notifier).saveAndUseSchema();

      expect(
        container.read(profileManagerProvider).currentProfile?.schemaId,
        '1.2.3',
      );
    });

    test('saveSchema throws error if canSave is false', () async {
      when(
        () => mockSchemaRepo.applicationExists('NonExistent'),
      ).thenAnswer((_) async => false);

      container
          .read(schemaEditorProvider.notifier)
          .updateManifest(targetAppName: 'NonExistent');

      // Wait for validation
      await Future.delayed(Duration.zero);

      expect(
        () => container.read(schemaEditorProvider.notifier).saveSchema(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Category Management', () {
    test('addCategory updates state', () {
      final category = CamCategoryEntry(
        categoryName: 'new_cat',
        categoryTitle: 'New Cat',
        categoryColorName: 'red',
      );
      container.read(schemaEditorProvider.notifier).addCategory(category);

      final categories = container.read(schemaEditorProvider).schema.categories;
      expect(categories.any((c) => c.categoryName == 'new_cat'), true);
    });

    test('updateCategory updates state and parameters', () {
      final oldCat = CamCategoryEntry(
        categoryName: 'old_cat',
        categoryTitle: 'Old Cat',
        categoryColorName: 'blue',
      );
      final newCat = CamCategoryEntry(
        categoryName: 'new_cat',
        categoryTitle: 'New Cat',
        categoryColorName: 'red',
      );
      final param = CamParamEntry(
        paramName: 'p1',
        paramTitle: 'P1',
        category: oldCat,
        value: 1.0,
        quantity: const ParamQuantity(
          quantityName: 'n',
          quantityUnit: 'u',
          quantitySymbol: 's',
          quantityType: QuantityType.numeric,
        ),
      );

      container.read(schemaEditorProvider.notifier).addCategory(oldCat);
      container.read(schemaEditorProvider.notifier).addParameter(param);

      container
          .read(schemaEditorProvider.notifier)
          .updateCategory('old_cat', newCat);

      final state = container.read(schemaEditorProvider);
      expect(
        state.schema.categories.any((c) => c.categoryName == 'new_cat'),
        true,
      );
      expect(
        state.schema.availableParameters.first.category.categoryName,
        'new_cat',
      );
    });

    test('deleteCategory moves parameters to default', () {
      final cat = CamCategoryEntry(
        categoryName: 'to_delete',
        categoryTitle: 'Title',
        categoryColorName: 'red',
      );
      final param = CamParamEntry(
        paramName: 'p1',
        paramTitle: 'P1',
        category: cat,
        value: 1.0,
        quantity: const ParamQuantity(
          quantityName: 'n',
          quantityUnit: 'u',
          quantitySymbol: 's',
          quantityType: QuantityType.numeric,
        ),
      );

      container.read(schemaEditorProvider.notifier).addCategory(cat);
      container.read(schemaEditorProvider.notifier).addParameter(param);

      container.read(schemaEditorProvider.notifier).deleteCategory('to_delete');

      final state = container.read(schemaEditorProvider);
      expect(
        state.schema.categories.any((c) => c.categoryName == 'to_delete'),
        false,
      );
      expect(
        state.schema.availableParameters.first.category.categoryName,
        'default',
      );
    });
  });

  group('Parameter Management', () {
    final tParam = CamParamEntry(
      paramName: 'p1',
      paramTitle: 'P1',
      category: CamCategoryEntry(
        categoryName: 'default',
        categoryTitle: 'Default',
        categoryColorName: 'blue',
      ),
      value: 1.0,
      quantity: const ParamQuantity(
        quantityName: 'n',
        quantityUnit: 'u',
        quantitySymbol: 's',
        quantityType: QuantityType.numeric,
      ),
    );

    test('addParameter updates state', () {
      container.read(schemaEditorProvider.notifier).addParameter(tParam);
      expect(
        container.read(schemaEditorProvider).schema.availableParameters.length,
        1,
      );
    });

    test('updateParameter updates state', () {
      container.read(schemaEditorProvider.notifier).addParameter(tParam);
      final updated = tParam.copyWith(paramTitle: 'Updated');
      container
          .read(schemaEditorProvider.notifier)
          .updateParameter('p1', updated);

      expect(
        container
            .read(schemaEditorProvider)
            .schema
            .availableParameters
            .first
            .paramTitle,
        'Updated',
      );
    });

    test('deleteParameter updates state', () {
      container.read(schemaEditorProvider.notifier).addParameter(tParam);
      container.read(schemaEditorProvider.notifier).deleteParameter('p1');
      expect(
        container.read(schemaEditorProvider).schema.availableParameters,
        isEmpty,
      );
    });

    test('addChildRelation adds a relation to parameter', () {
      container.read(schemaEditorProvider.notifier).addParameter(tParam);
      container
          .read(schemaEditorProvider.notifier)
          .addChildRelation('p1', 'child_p');

      final param = container
          .read(schemaEditorProvider)
          .schema
          .availableParameters
          .first;
      expect(param.children.length, 1);
      expect(param.children.first.childParamName, 'child_p');
    });

    test('removeChildRelation removes relation', () {
      container.read(schemaEditorProvider.notifier).addParameter(tParam);
      container
          .read(schemaEditorProvider.notifier)
          .addChildRelation('p1', 'child_p');
      container
          .read(schemaEditorProvider.notifier)
          .removeChildRelation('p1', 'child_p');

      final param = container
          .read(schemaEditorProvider)
          .schema
          .availableParameters
          .first;
      expect(param.children, isEmpty);
    });
  });
}
