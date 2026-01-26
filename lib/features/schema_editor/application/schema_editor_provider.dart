import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_state.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/features/schema_shop/domain/entities/schema_manifest.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_category_manager.dart';
import 'package:laminode_app/features/schema_editor/application/schema_editor_parameter_manager.dart';
import 'package:laminode_app/core/services/graph_debug_service.dart';
import 'package:laminode_app/features/profile_manager/domain/entities/profile_entity.dart';

import 'package:laminode_app/features/schema_shop/presentation/providers/schema_shop_provider.dart';
import 'package:laminode_app/features/profile_manager/presentation/providers/profile_manager_provider.dart';

import 'package:laminode_app/features/schema_editor/application/schema_export_service.dart';

class SchemaEditorNotifier extends Notifier<SchemaEditorState>
    with SchemaEditorCategoryManager, SchemaEditorParameterManager {
  @override
  SchemaEditorState build() {
    return SchemaEditorState(
      schema: CamSchemaEntry(
        schemaName: 'New Schema',
        categories: [
          CamCategoryEntry(
            categoryName: 'default',
            categoryTitle: 'Default',
            categoryColorName: 'blue',
          ),
        ],
        availableParameters: [],
      ),
      manifest: SchemaManifest(
        schemaType: 'application',
        schemaVersion: '1.0.0',
        schemaAuthors: [],
        lastUpdated: DateTime.now().toIso8601String(),
        targetAppName: 'New Schema',
        targetAppVersion: '1.0',
        targetAppSector: 'FDM',
      ),
      adapterCode:
          '// Adapter Logic\n\nfunction exportProfile(profile) {\n  return "G1 X0 Y0";\n}\n',
    );
  }

  Future<void> validate() async {
    final repo = ref.read(schemaShopRepositoryProvider);
    final appName = state.manifest.targetAppName;
    final appVersion = state.manifest.targetAppVersion;
    final schemaId = state.manifest.schemaVersion;

    bool appExists = false;
    bool versionExists = false;

    if (appName != null && appName.isNotEmpty) {
      appExists = await repo.applicationExists(appName);

      if (appVersion != null && appVersion.isNotEmpty && schemaId.isNotEmpty) {
        versionExists = await repo.schemaExists(appName, appVersion, schemaId);
      }
    }

    state = state.copyWith(
      isChecking: false,
      appExists: appExists,
      versionExists: versionExists,
    );
  }

  void loadSchema(
    CamSchemaEntry schema,
    SchemaManifest manifest, {
    String? adapterCode,
  }) {
    GraphDebugService.talker.info('Loading schema: ${schema.schemaName}');
    state = state.copyWith(
      schema: schema,
      manifest: manifest,
      adapterCode: adapterCode ?? state.adapterCode,
      viewMode: SchemaEditorViewMode.schema,
      clearSelectedParameter: true,
      clearSelectedCategory: true,
    );
    validate();
  }

  void updateManifest({
    String? schemaVersion,
    List<String>? schemaAuthors,
    String? targetAppName,
    String? targetAppVersion,
    String? targetAppSector,
  }) {
    final current = state.manifest;
    GraphDebugService.talker.debug('Updating schema manifest');
    state = state.copyWith(
      manifest: SchemaManifest(
        schemaType: current.schemaType,
        schemaVersion: schemaVersion ?? current.schemaVersion,
        schemaAuthors: schemaAuthors ?? current.schemaAuthors,
        lastUpdated: DateTime.now().toIso8601String(),
        targetAppName: targetAppName ?? current.targetAppName,
        targetAppVersion: targetAppVersion ?? current.targetAppVersion,
        targetAppSector: targetAppSector ?? current.targetAppSector,
      ),
    );

    // Sync schemaName with targetAppName if changed
    if (targetAppName != null && targetAppName != state.schema.schemaName) {
      GraphDebugService.talker.debug(
        'Syncing schema name with target app name: $targetAppName',
      );
      state = state.copyWith(
        schema: CamSchemaEntry(
          schemaName: targetAppName,
          categories: state.schema.categories,
          availableParameters: state.schema.availableParameters,
        ),
      );
    }
    validate();
  }

  void setViewMode(SchemaEditorViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void toggleCategoryFilter() {
    state = state.copyWith(filterByCategories: !state.filterByCategories);
  }

  void updateAdapterCode(String code) {
    GraphDebugService.talker.debug(
      'Updating adapter code (${code.length} chars)',
    );
    state = state.copyWith(adapterCode: code);
  }

  Future<void> saveSchema() async {
    if (!state.canSave) {
      throw Exception('Saving is not allowed in current state');
    }

    final repo = ref.read(schemaShopRepositoryProvider);
    final schemaJson = SchemaExportService.schemaToRawJson(state);
    final appName = state.manifest.targetAppName!;
    final appVersion = state.manifest.targetAppVersion ?? "1.0";
    final schemaId = state.manifest.schemaVersion;

    await repo.saveSchema(
      appName,
      appVersion,
      schemaId,
      schemaJson,
      state.adapterCode,
    );
    ref.invalidate(schemaShopProvider);
    validate(); // Refresh version check
  }

  Future<void> saveAndUseSchema() async {
    await saveSchema();

    final appName = state.manifest.targetAppName ?? "Unknown App";
    final appVersion = state.manifest.targetAppVersion ?? "1.0";

    final application = ProfileApplication(
      id: appName.replaceAll(' ', '_').toLowerCase(),
      name: appName,
      vendor: "Local User",
      version: appVersion,
    );

    final manifest = ProfileSchemaManifest(
      id: state.manifest.schemaVersion,
      version: state.manifest.schemaVersion,
      updated: DateTime.now().toIso8601String(),
      targetAppName: appName,
      type: state.manifest.schemaType,
    );

    final profileNotifier = ref.read(profileManagerProvider.notifier);
    profileNotifier.setApplication(application);
    profileNotifier.setSchema(manifest);
  }

  Future<void> exportSchema() async {
    await SchemaExportService.exportSchemaBundle(state);
  }
}

final schemaEditorProvider =
    NotifierProvider<SchemaEditorNotifier, SchemaEditorState>(
      SchemaEditorNotifier.new,
    );
